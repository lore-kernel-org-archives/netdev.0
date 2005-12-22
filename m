From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.15-rc6: known regressions in the kernel Bugzilla
Date: Thu, 22 Dec 2005 02:13:20 +0100
Message-ID: <20051222011320.GL3917@stusta.de>
References: <Pine.LNX.4.64.0512181641580.4827@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	aabdulla@nvidia.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	ak@suse.de, discuss@x86-64.org, perex@suse.cz,
	alsa-devel@alsa-project.org, gregkh@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965008AbVLVBNX@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0512181641580.4827@g5.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following bugs in the kernel Bugzilla [1] contain regressions in 
2.6.15-rc compared to 2.6.14 with patches:
- #5632 forcedeth driver occasionally hangs
- #5758 x86_64: PANIC: early exception

The following bug in the kernel Bugzilla contains a regressions in 
2.6.15-rc without a patch:
- #5760 No sound with snd_intel8x0 & ALi M5455 chipset
        (kobject_register failed)

If we want people to test -rc kernels, we should also try hard to fix 
the regressions they report (even more if there are already patches 
for them)...

I've Cc'ed all people who might be able comment on one or more of these 
issues.

cu
Adrian

[1] http://bugzilla.kernel.org/

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
