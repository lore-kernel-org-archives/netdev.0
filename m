From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 08:41:40 +0100
Message-ID: <5cac192f050102234168b40bc@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <5cac192f0501021530672a908a@mail.gmail.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

> Two (untested) patches implementing what I described above.
> 
> The first pach (sch_generic.patch) keeps queue_lock held in
> qdisc_restart() when calling hard_start_xmit() of a LLTX driver. The
> second (sungem.patch) makes sungem release queue_lock after grabbing
> its private tx lock.
> 
> Note that the modifications made to qdisc_restart() are not compatible
> with the current LLTX drivers. All LLTX drivers must be modified along
> sungem.patch's lines. Take sungem.patch as an example of how things
> must be done.

Correction: the current LLTX drivers need not be modified to work
correctly. However, as an opimisation, they can modified along
sungem.patch's line.

Thanks,
-- 
Eric
