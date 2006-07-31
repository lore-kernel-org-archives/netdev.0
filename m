From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules Framework
Date: Mon, 31 Jul 2006 22:01:26 +0200
Message-ID: <20060731200126.GL14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch> <44CE17B6.2070108@tcs.hut.fi> <20060731152401.GI14627@postel.suug.ch> <44CE4594.1030505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>,
	David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55768 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751317AbWGaUBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 16:01:06 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44CE4594.1030505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-07-31 20:01
> Thomas Graf wrote:
> > * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-07-31 17:46
> >
> >>Shouldn't all these (struct fib_rule_hdr included) actually be defined
> >>in include/linux/rtnetlink.h?
> > 
> > 
> > We used to stuff everything into rtnetlink.h for no good reason. Having
> > independant include/linux/<subsystem>.h to export the interface to
> > userspace and include/net/<subsystem>.h to export the kernel interface
> > instead of contributing to the ifdef hell seems a lot cleaner to me.
> 
> 
> I agree, but then we should also split up rtnetlink.h. Having one
> special case will just make it harder to find.

Already done in the patchset converting things to the new netlink
interface that I'll start submiting in the next days.
