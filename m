From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 4 Apr 2008 11:50:33 +0200
Message-ID: <200804041150.34046.rjw@sisk.pl>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net> <20080403211913.3a0c1d00.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Robin H. Johnson" <robbat2@gentoo.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Ilpo =?iso-8859-1?q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:37650 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658AbYDDJu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 05:50:29 -0400
In-Reply-To: <20080403211913.3a0c1d00.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 4 of April 2008, Andrew Morton wrote:
> 
> (cc netdev)
> 
> (and Rafael - I assume 2.6.24 didn't do this..)
> 
> On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.org> wrote:

That's http://bugzilla.kernel.org/show_bug.cgi?id=10346 , I think. 

Robin, please add yourself to the CC list in the bugzilla entry above.

> > One of the nodes in my web-serving cluster (isohunt.com) started showing this:
> > 
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
> > Modules linked in: lm85 hwmon_vid nfs lockd nfs_acl sunrpc bonding reiserfs k8temp hwmon i2c_nforce2 i2c_core sg
> > Pid: 32500, comm: php-cgi Not tainted 2.6.25-rc4-git2 #7
> > 
> > Call Trace:
> >  <IRQ>  [<ffffffff80233d2f>] warn_on_slowpath+0x5f/0x80
> >  [<ffffffff8057ec9e>] ? __qdisc_run+0xae/0x210
> >  [<ffffffff8056f8b6>] ? dev_queue_xmit+0xb6/0x350
> >  [<ffffffff805904e0>] ? ip_finish_output+0x0/0x2d0
> >  [<ffffffff8059061f>] ? ip_finish_output+0x13f/0x2d0
> >  [<ffffffff8059b9a3>] tcp_mark_head_lost+0x173/0x1a0
> >  [<ffffffff8059e4f9>] tcp_ack+0x1719/0x2050
> >  [<ffffffff805a2188>] tcp_rcv_established+0x438/0x9c0
> >  [<ffffffff805c91a5>] ? ip_vs_in+0x215/0x2b0
> >  [<ffffffff805a8665>] tcp_v4_do_rcv+0xd5/0x210
> >  [<ffffffff80594349>] ? __inet_lookup_established+0xf9/0x1b0
> >  [<ffffffff805aa005>] tcp_v4_rcv+0x4a5/0x830
> >  [<ffffffff8058c0c5>] ip_local_deliver_finish+0x65/0x1b0
> >  [<ffffffff8058c66b>] ip_local_deliver+0x3b/0x90
> >  [<ffffffff8058be40>] ip_rcv_finish+0x120/0x340
> >  [<ffffffff8058c53a>] ip_rcv+0x1fa/0x2f0
> >  [<ffffffff8056c788>] netif_receive_skb+0x2a8/0x330
> >  [<ffffffff803ea9f7>] e1000_clean_rx_irq+0x1a7/0x5a0
> >  [<ffffffff803e5f2f>] e1000_clean+0x6f/0x290
> >  [<ffffffff8056ed99>] net_rx_action+0x109/0x210
> >  [<ffffffff80239a04>] __do_softirq+0x74/0xe0
> >  [<ffffffff8020c66c>] call_softirq+0x1c/0x30
> >  [<ffffffff8020eb5d>] do_softirq+0x3d/0x80
> >  [<ffffffff80239985>] irq_exit+0x45/0x50
> >  [<ffffffff8020ec55>] do_IRQ+0x85/0x100
> >  [<ffffffff8020b9f1>] ret_from_intr+0x0/0xa
> >  <EOI> 
> > ---[ end trace cd81b9a520cecbe0 ]---
> > 
> > .config attached.
> 
> 
> 



-- 
"Premature optimization is the root of all evil." - Donald Knuth
