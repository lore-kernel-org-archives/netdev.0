From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Fri, 04 Aug 2006 16:59:31 -0700 (PDT)
Message-ID: <20060804.165931.48505912.davem@davemloft.net>
References: <9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
	<20060730.155640.10246145.davem@davemloft.net>
	<9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, shemminger@osdl.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45766
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161590AbWHDX7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 19:59:24 -0400
To: jesper.juhl@gmail.com
In-Reply-To: <9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Sat, 5 Aug 2006 01:30:49 +0200

> On 31/07/06, David Miller <davem@davemloft.net> wrote:
> > From: "Jesper Juhl" <jesper.juhl@gmail.com>
> > Date: Sun, 30 Jul 2006 23:51:20 +0200
> >
> > > Looks ok to me.
> >
> > I've applied James's version of the fix, thanks everyone.
> >
> Hmm, if you are refering to commit
> 118075b3cdc90e0815362365f3fc64d672ace0d6 -
> http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=118075b3cdc90e0815362365f3fc64d672ace0d6
> then I think a mistake has crept in. That commit only initializes
> 'cnt' to 0 - I don't see how that would fix the leak - looks like you
> forgot the business end of the patch...

See the commit right before that, the initialize of cnt to
zero is just to fix a compiler warning that resulted from
James's version of the fix.
