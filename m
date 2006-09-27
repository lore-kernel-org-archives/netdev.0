From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 12:09:39 +0200
Message-ID: <20060927100939.GZ18349@postel.suug.ch>
References: <20060926183621.GX18349@postel.suug.ch> <Pine.LNX.4.44.0609271104470.9010-100000@dhcp09282.ntc.nokia.com> <20060927093301.GY18349@postel.suug.ch> <451A480F.7050404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50882 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965492AbWI0KJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 06:09:19 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <451A480F.7050404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-09-27 11:44
> Thomas Graf wrote:
> > * Nordlund Kim (Nokia-NET/Helsinki) <Kim.Nordlund@nokia.com> 2006-09-27 11:50
> > 
> >>So I would suggest to apply this patch to be compatible with the
> >>GCC version in RHEL5, and simply to make code clearer (to the
> >>intended idea).
> > 
> > 
> > Yes.
> 
> I don't care much about this small change, but I think bugs
> should be fixed where they originate.

Absolutely, I'm not even sure who's fault it really is. When
writing that code I must have expected gcc to correctly
underflow which might have been a wrong assumption.

I think it doesn't matter whether this is a gcc bug or not,
having this code part wort with gcc 4.1 is a good thing anyway.

> If RH's gcc miscompiles
> this with -Os I wouldn't trust it anyway, and the easy way to
> fix it seems to be to deactivate CONFIG_CC_OPTIMIZE_FOR_SIZE,
> which even includes a big warning of broken compilers.

gcc >= 4.1 seems to produce this code with either -Os or -O2
so the range of affected useres might in fact be bigger.

> What about the similar code in u32 and cbq?

Not affected by this.
