From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH net-next v3.16]r8169:  Correct value from speed 10 on
 MII_BMCR
Date: Sat, 26 Mar 2016 00:51:31 +0100
Message-ID: <20160325234942.19FA762813@mail.nwl.cc>
References: <1458910866-21784-1-git-send-email-asd@marian1000.go.ro>
 <20160325133113.3001B62813@mail.nwl.cc>
 <20160325225325.GA28935@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53872 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbcCYXto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 19:49:44 -0400
Content-Disposition: inline
In-Reply-To: <20160325225325.GA28935@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 11:53:25PM +0100, Francois Romieu wrote:
> Phil Sutter <phil@nwl.cc> :
> [...]
> > Your patch submissions are getting better, also good to see you're
> > finally using git-send-email. A few things need to be corrected though:
> > 
> 
> #define BMCR_RESV               0x003f  /* Unused...                   */
> #define BMCR_SPEED1000          0x0040  /* MSB of Speed (1000)         */
> #define BMCR_CTST               0x0080  /* Collision test              */
> #define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
> #define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */
> #define BMCR_ISOLATE            0x0400  /* Isolate data paths from MII */
> #define BMCR_PDOWN              0x0800  /* Enable low power state      */
> #define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
> #define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
> #define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */
> 
> BMCR_SPEED100 apart, *all* these bits are now set.
> 
> It does not make much sense.

I presumed that already, but didn't care to check myself so instead
ignored the actual code change. Thanks for pointing out the futility of
the whole thing. :)

> > Also detailed instructions on how to trigger the problem you are fixing
> > for would be good. In detail: Which specific hardware was used, in which
> > situation did the problem occur, how did it behave in that situation and
> > what was the expected behaviour?
> 
> Been there. Such requests are usually left unanswered. :o(

That's my impression from following the (somewhat amusing) former
threads, too. I was merely impressed by the sheer quality of this patch
in comparison to previous ones. Speaking of which, the presented
tenacity certainly earns some respect.

Cheers, Phil
