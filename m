From: Alex Davis <alex14641@yahoo.com>
Subject: Re: System hangs after running 2.6.17rc6 with broadcom 4309 and device scape stack
Date: Fri, 23 Jun 2006 12:38:21 -0700 (PDT)
Message-ID: <20060623193821.14053.qmail@web50206.mail.yahoo.com>
References: <20060623141325.0de4970e@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50206.mail.yahoo.com ([206.190.38.47]:35669 "HELO
	web50206.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1751959AbWFWTiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 15:38:22 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060623141325.0de4970e@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Jiri Benc <jbenc@suse.cz> wrote:

> On Sun, 18 Jun 2006 18:25:54 -0700 (PDT), Alex Davis wrote:
> > Here is dmesg output for module loading.
> > [...]
> > Jun 16 20:04:06 siafu kernel: [4294720.505000] bcm43xx_d80211: Virtual interface added (type:
> > 0x00000002, ID: 4, MAC: 00:90:96:ba:32:20)
> > Jun 16 20:04:06 siafu kernel: [4294720.511000] bcm43xx_d80211: PHY connected
> > Jun 16 20:04:07 siafu kernel: [4294720.779000] bcm43xx_d80211: Radio turned on
> > Jun 16 20:04:07 siafu kernel: [4294720.971000] bcm43xx_d80211: Chip initialized
> > Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: DMA initialized
> > Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: 80211 cores initialized
> > Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: Keys cleared
> > Jun 16 20:04:07 siafu kernel: [4294720.988000] wmaster0: Does not support passive scan,
> disabled
> > Jun 16 20:04:09 siafu kernel: [4294723.027000] bcm43xx_d80211: ASSERTION FAILED
> > (bcm->interface.if_id == if_id) at:
> > drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:4344:bcm43xx_config_interface()
> 
> This is really strange. Is this reproducible with latest wireless-dev?
I was using the latest: John Linville's git development release (2.6.17rc6).
I cloned it from git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
on 6/15/2006 21:00 EDT. As of today (6/23), there have been no changes.

> There was ifconfig up (or similar) command at 20:04:06 but
> wpa_supplicant was started at 20:04:14. What happened in-between?
Nothing. I start everything up by hand, hence the delay.

I use the following commands:
modprobe bcm43xx-d80211
wpa_supplicant -i wlan0 ....
dmesg  # to make sure I'm associated with the access point, and see any debugging info.
dhcpcd wlan0
ping ....
login as non-root user and start x.


> Most important, what happened between 20:04:07 and 20:04:09? (I.e. what
> commands were invoked?) 
No commands were invoked during that period.


I'm currently using the rc5 version with no problems.


> Thanks,
> 
>  Jiri
> 
> -- 
> Jiri Benc
> SUSE Labs
> 


I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
