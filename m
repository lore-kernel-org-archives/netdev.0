From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 17:41:05 +0100
Message-ID: <5cac192f05010308414a25b548@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, Andi Kleen <ak@suse.de>,
	openib-general@openib.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52brc68q05.fsf@topspin.com>
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

On Mon, 03 Jan 2005 07:57:14 -0800, Roland Dreier <roland@topspin.com> wrote:
>     jamal> Andi or anyone else - has anyone really done perfomance
>     jamal> analysis of LLTX (with anything other than loopback) and
>     jamal> shown it has any value? Maybe time to just shoot the damn
>     jamal> thing.
> 
> For the IPoIB driver, it seems to be worth a couple percent.  It's
> hard to get really consistent results but on my pair of test systems,
> TCP throughput with netperf goes up by about 30 Mbps out of roughly
> 1900 Mbps total.  It's probably not worth the complexity in the net
> core if all drivers only get that level of improvement.
> 
>  - Roland
> 

What are your machines? In particular, how many CPUs do they have?

-- 
Eric
