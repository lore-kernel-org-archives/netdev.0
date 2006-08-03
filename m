From: Jiri Benc <jbenc@suse.cz>
Subject: Re: System hangs after running 2.6.17rc6 with broadcom 4309 and
 device scape stack
Date: Thu, 3 Aug 2006 15:40:14 +0200
Message-ID: <20060803154014.5aa83377@griffin.suse.cz>
References: <20060619012554.5438.qmail@web50207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:29608 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932362AbWHCNkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 09:40:17 -0400
To: Alex Davis <alex14641@yahoo.com>
In-Reply-To: <20060619012554.5438.qmail@web50207.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Jun 2006 18:25:54 -0700 (PDT), Alex Davis wrote:
> > After running 2.6.17rc6 with device scape stack 
> > (git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git)
> > for a few hours, my system hangs. Here is the last thing I see in my logs:
> > 
> > [...]
> 
> Some more info:
> Here is dmesg output for module loading.
> [...]
> Jun 16 20:04:09 siafu kernel: [4294723.027000] bcm43xx_d80211: ASSERTION FAILED
> (bcm->interface.if_id == if_id) at:
> drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:4344:bcm43xx_config_interface()

This is fixed now ("more correct WE support on master interface" patch I
sent today).

The second problem you were encountering (bcm->mac_suspended >= 0
assertion failures) should be fixed at this time too.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
