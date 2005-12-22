From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.15-rc6: known regressions in the kernel Bugzilla
Date: Wed, 21 Dec 2005 23:15:57 -0800
Message-ID: <20051222071557.GA17346@suse.de>
References: <Pine.LNX.4.64.0512181641580.4827@g5.osdl.org> <20051222011320.GL3917@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	aabdulla@nvidia.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	ak@suse.de, discuss@x86-64.org, perex@suse.cz,
	alsa-devel@alsa-project.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965097AbVLVHRh@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051222011320.GL3917@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2005 at 02:13:20AM +0100, Adrian Bunk wrote:
> The following bug in the kernel Bugzilla contains a regressions in 
> 2.6.15-rc without a patch:
> - #5760 No sound with snd_intel8x0 & ALi M5455 chipset
>         (kobject_register failed)

We put code in the kobjet to report when callers fail, due to problems
in them, and the kobject code is blamed...

Looks like a sound driver issue, nothing has changed in the kobject
code.

thanks,

greg k-h
