From: Ookhoi <ookhoi@humilis.net>
Subject: Re: e1000 -> 82540EM on linux 2.6.0-test[45] very slow in one direction
Date: Fri, 3 Oct 2003 14:23:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003122329.GA21532@favonius>
References: <bkeli5$8l2$1@sea.gmane.org> <ble1ma$ul9$1@sea.gmane.org> <20031003103025.GA20676@favonius>
Reply-To: ookhoi@humilis.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Zwoch <zwoch@backendmedia.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ookhoi <ookhoi@humilis.net>
Content-Disposition: inline
In-Reply-To: <20031003103025.GA20676@favonius>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ookhoi wrote (ao):
> Florian Zwoch wrote (ao):
> > issue seems to partly solved. the e1000 driver seems to be ok!
> > i reconfigured my kernel and intentionally left out netfilter options. 
> > after that my network performance was back to normal.
> > 
> > netfilter was only compiled in the kernel. it was not used with any rules!
> > 
> > so my wild guess would be that something with the netfilter code (i am 
> > not 100% sure it was netfilter.. _maybe_ it was some small odd kernel 
> > option i accidently enabled/disabled) is broken since test3 (again 
> > uncertified. but i firstly noticed this switching from test3 to test4).

> I have netfilter enabled, and will try another -test6 kernel with
> netfilter not compiled in to see if that indeed makes a difference.

I can confirm now that disabling netfilter in 2.6.0-test6 makes the nic
perform oke wrt upload.
I (just like Florian) had no iptables rules active in the former
2.6.0-test6 kernel, but netfilter was compiled in.
