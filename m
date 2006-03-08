From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 07 Mar 2006 17:34:34 -0800
Message-ID: <ada4q29ra6t.fsf@cisco.com>
References: <1141776697.6119.938.camel@localhost>
	<20060307.161808.60227862.davem@davemloft.net>
	<adaacc1raz9.fsf@cisco.com>
	<20060307.172336.107863253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org, shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060307.172336.107863253.davem@davemloft.net> (David S.
	Miller's message of "Tue, 07 Mar 2006 17:23:36 -0800 (PST)")
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

    David> I wish you had started the thread by mentioning this
    David> specific patch, we wasted an enormous amount of precious
    David> developer time speculating and asking for arbitrary tests
    David> to be run in order to narrow down the problem, yet you knew
    David> the specific change that introduced the performance
    David> regression already...

Sorry, you're right.  I was a little confused because I had a memory of
Michael's original email (http://lkml.org/lkml/2006/3/6/150) quoting a
changelog entry, but looking back at the message, it was quoting
something completely different and misleading.

I think the most interesting email in the old thread is
http://openib.org/pipermail/openib-general/2005-October/012482.html
which shows that reverting 314324121 (the "stretch ACK performance
killer" fix) gives ~400 Mbit/sec in extra IPoIB performance.

 - R.
