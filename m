From: Jiri Benc <jbenc@suse.cz>
Subject: Re: System hangs after running 2.6.17rc6 with broadcom 4309 and
 device scape stack
Date: Fri, 23 Jun 2006 14:13:25 +0200
Message-ID: <20060623141325.0de4970e@griffin.suse.cz>
References: <20060619012554.5438.qmail@web50207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10127 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S933085AbWFWMN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:13:29 -0400
To: Alex Davis <alex14641@yahoo.com>
In-Reply-To: <20060619012554.5438.qmail@web50207.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Jun 2006 18:25:54 -0700 (PDT), Alex Davis wrote:
> Here is dmesg output for module loading.
> [...]
> Jun 16 20:04:06 siafu kernel: [4294720.505000] bcm43xx_d80211: Virtual interface added (type:
> 0x00000002, ID: 4, MAC: 00:90:96:ba:32:20)
> Jun 16 20:04:06 siafu kernel: [4294720.511000] bcm43xx_d80211: PHY connected
> Jun 16 20:04:07 siafu kernel: [4294720.779000] bcm43xx_d80211: Radio turned on
> Jun 16 20:04:07 siafu kernel: [4294720.971000] bcm43xx_d80211: Chip initialized
> Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: DMA initialized
> Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: 80211 cores initialized
> Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: Keys cleared
> Jun 16 20:04:07 siafu kernel: [4294720.988000] wmaster0: Does not support passive scan, disabled
> Jun 16 20:04:09 siafu kernel: [4294723.027000] bcm43xx_d80211: ASSERTION FAILED
> (bcm->interface.if_id == if_id) at:
> drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:4344:bcm43xx_config_interface()

This is really strange. Is this reproducible with latest wireless-dev?

There was ifconfig up (or similar) command at 20:04:06 but
wpa_supplicant was started at 20:04:14. What happened in-between?

Most important, what happened between 20:04:07 and 20:04:09? (I.e. what
commands were invoked?) 

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
