From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: kernel crashes inside MV643xx driver
Date: Wed, 5 Sep 2007 09:54:52 -0700
Message-ID: <20070905165452.GA18396@xyzzy.farnsworth.org>
References: <46C93701.7050509@alcatel-lucent.com> <20070905082452.4a20387b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gshan <gshan@alcatel-lucent.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60647 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755061AbXIERCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 13:02:16 -0400
Content-Disposition: inline
In-Reply-To: <20070905082452.4a20387b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 05, 2007 at 08:24:52AM -0700, Andrew Morton wrote:
> > On Mon, 20 Aug 2007 14:38:57 +0800 gshan <gshan@alcatel-lucent.com> wrote:
> > Hi All,
> > 
> > After I started the NFS server, it crashed:
> > 
> > <3>Badness in local_bh_enable at 
> > /home/cli4/sandbox/main/TelicaRoot/components/mvlinux/cge/devkit/lsp/7xx/linux/kernel/softirq.c:195
> > Badness in local_bh_enable at 
> > /home/cli4/sandbox/main/TelicaRoot/components/mvlinux/cge/devkit/lsp/7xx/linux/kernel/softirq.c:195
> > Call trace:
> >  [c0005340] check_bug_trap+0xbc/0x11c
> >  [c0005604] ProgramCheckException+0x264/0x2bc
> >  [c0004ac4] ret_from_except_full+0x0/0x4c
> >  [c0022ae4] local_bh_enable+0x18/0x80
> >  [c024648c] skb_copy_bits+0x168/0x3b8
> >  [c024db44] __skb_linearize+0x90/0x150
> >  [c020e8a4] mv643xx_eth_start_xmit+0x4c0/0x5bc
> >  [c025c934] qdisc_restart+0xac/0x2bc
> >  [c024de9c] dev_queue_xmit+0x298/0x34c
> >  [c0269814] ip_finish_output+0x140/0x2b8
> >  [c026a3ac] ip_fragment+0x3cc/0x6e0
> >  [c026bac8] ip_push_pending_frames+0x3dc/0x46c
> >  [c0289ec4] udp_push_pending_frames+0x10c/0x1cc
> >  [c028a7c4] udp_sendpage+0x104/0x188
> >  [c0292fc8] inet_sendpage+0x90/0xb8
> > 
> > I searched the webs and found the similar problems:
> > http://www.mail-archive.com/netdev@vger.kernel.org/msg05199.html
> > http://oss.sgi.com/archives/netdev/2005-09/msg00025.html
> > 
> > Who knew there are fixes for the problem?
> > 
> 
> Well that got a tremendous response, didn't it?
> 
> What do you mean by "crashed"?  The above is a warning and the system
> should have survived.
> 
> Which kernel version is being used?

That is the key question.  From the pathnames, I suspect that gshan is
using a MontaVista version.  I'm still (especially) interested, since
MontaVista pays me.

BTW, I never received the original message on netdev or linux-kernel.
Hmm.  Thanks to Andrew for replying.

-Dale
