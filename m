From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: > with unpatched kernels, and if you tried other than 2.6.25
	versions
Date: Thu, 12 Jun 2008 22:15:49 +0200
Message-ID: <20080612201548.GA2472@ami.dom.local>
References: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com> <4851116A.6040805@trash.net> <43d009740806120524g78d066d2x95640fc8e01be625@mail.gmail.com> <485115EE.1040204@trash.net> <48517ACD.4020209@gmail.com> <48517D1C.7010308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Igor M Podlesny <for.poige+linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:33879 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbYFLUQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 16:16:23 -0400
Received: by gv-out-0910.google.com with SMTP id e6so929092gvc.37
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 13:16:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48517D1C.7010308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2008 at 03:46:36AM +0800, Igor M Podlesny wrote:
> On 2008-06-13 03:36, Jarek Poplawski wrote:
> > Patrick McHardy wrote, On 06/12/2008 02:26 PM:
> [...]
> > 
> > Igor, probably for this list it's more interesting if it's reproducible
> > with unpatched kernels, and if you tried other than 2.6.25 versions
> > for this?
> > 
> > Thanks,
> > Jarek P.
> 
> 	Recently I got another one (several times, actually):
> 
> [105373.451522] swapper: page allocation failure. order:2, mode:0x4020
> [105373.451527] Pid: 0, comm: swapper Tainted: P         2.6.25.6aa-gcc43 #1
> [105373.451540]  [<c0157670>] __alloc_pages+0x2af/0x2c7
> [105373.451550]  [<c015770f>] __get_free_pages+0x3c/0x4d
> [105373.451553]  [<c02ec2e1>] __alloc_skb+0x49/0xf6
> [105373.451558]  [<f8b65b9d>] nv_alloc_rx_optimized+0x45/0x15d [forcedeth]
> [105373.451567]  [<f8b6a768>] nv_napi_poll+0x50f/0x5e7 [forcedeth]
> [105373.451577]  [<c02ef173>] net_rx_action+0x65/0x158
> [105373.451582]  [<c012fa8a>] __do_softirq+0x5a/0xa8
> [105373.451588]  [<c012fb0a>] do_softirq+0x32/0x36
> [105373.451591]  [<c012fc5f>] irq_exit+0x35/0x76
> [105373.451594]  [<c01157c7>] do_IRQ+0x54/0x65
> [105373.451599]  [<c0113c0f>] common_interrupt+0x23/0x28
> [105373.451607]  [<c011238c>] default_idle+0x36/0x5a
> [105373.451610]  [<c0112356>] default_idle+0x0/0x5a
> [105373.451613]  [<c0112326>] cpu_idle+0x8c/0xbc
> [105373.451620]  =======================
> 
> $ uname -sr
> Linux 2.6.25.6aa-gcc43
> 
> BTW, it's unclear, would it be better to have rebooted the comp. immediately after
> getting those messages?

Hm... hard to tell. This shouldn't happen and rebooting isn't a solution.
Try to eliminate this (is it patched kernel BTW?). Check your hardware
and maybe try a more current kernel (e.g. 2.6.26-rc5).

BTW, is it your mailer or some memory problems: this message has strange
"Subject"...

Jarek P.
