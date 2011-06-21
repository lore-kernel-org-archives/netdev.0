From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 13:46:45 -0700
Message-ID: <20110621134645.e58284fa.randy.dunlap@oracle.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
	<20110621130929.ddd107f7.rdunlap@xenotime.net>
	<20110621203720.GB16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64911 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757177Ab1FUUrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:47:21 -0400
In-Reply-To: <20110621203720.GB16021@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 22:37:20 +0200 Florian Westphal wrote:

> Randy Dunlap <rdunlap@xenotime.net> wrote:
> > > diff --git a/Documentation/networking/sysrq-ping.txt b/Documentation/networking/sysrq-ping.txt
> > > new file mode 100644
> > > index 0000000..efa8be3
> > > --- /dev/null
> > > +++ b/Documentation/networking/sysrq-ping.txt
> > > @@ -0,0 +1,26 @@
> > > +In some circumstances, a system can hang/lockup in such a way that the system
> > > +is completely unresponsive to keyboard or console input but is still
> > > +responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> > > +net/ipv4/sysrq-ping.ko which allows a root user to configure the system for a
> > 
> > or it can be built-in the kernel image... (i.e., not a loadable module)
> > 
> > > +remote sysrq.
> > > +
> > > +To use this do:
> > > +
> > > +mount -t debugfs none /sys/kernel/debug/
> > > +echo 1 > /proc/sys/kernel/sysrq
> > > +echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
> > > +echo 1 > /sys/kernel/debug/network_sysrq_enable
> > 
> > so all of this (insecure) stuff has to be done before you suspect that
> > you need it .. in case the local keyboard/console is dead.
> 
> There is an xt_SYSREQ module in xtables-addons package (i.e., a
> netfilter target), it supports hashed passwords and has some sequence
> number scheme to avoid replays.
> 
> I think it would make more sense to merge that upstream, simply because
> it seems to be a bit more advanced...

in which case I would prefer this patch instead of a netfilter patch.  :)

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
