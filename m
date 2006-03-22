From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 2.6.16-rc6 1/1] ipw2200: Add Kconfig entries for QOS
	and Monitor mode
Date: Wed, 22 Mar 2006 11:11:37 +0800
Message-ID: <1142997102.17270.131.camel@debian.sh.intel.com>
References: <20060303045651.1f3b55ec.akpm@osdl.org>
	 <20060303152641.GR9295@stusta.de>
	 <200603050146.27529.andreashappe@snikt.net>
	 <20060307170642.GE3974@stusta.de> <20060303045651.1f3b55ec.akpm@osdl.org>
	 <20060303152641.GR9295@stusta.de>
	 <200603050146.27529.andreashappe@snikt.net>
	 <20060317191447.GC21830@tuxdriver.com> <20060318174703.GA22072@localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750717AbWCVDUJ@vger.kernel.org>
To: Andreas Happe <andreashappe@snikt.net>
In-Reply-To: <20060318174703.GA22072@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-03-18 at 18:47 +0100, Andreas Happe wrote:
> Adds Kconfig entries for enabling Monitor mode and Quality of service
> to the ipw2200 driver. It also renames the IPW_QOS define to
> IPW2200_QOS.
> 
> As Monitor mode generates lots of firmware errors it depends upon
> BROKEN. QOS is under development, so it depends upon EXPERIMENTAL.

Ack the rename and QoS description changes.

The IPW2200_MONITOR and monitor mode firmware error are already fixed in
wireless-2.6 GIT
http://kernel.org/git/?p=linux/kernel/git/linville/wireless-2.6.git;a=summary

Wireless related development happens there. I'd suggest you create
patches against that tree.

Thanks,
-yi
