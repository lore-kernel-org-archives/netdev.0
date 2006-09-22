From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: Bcm43xx softMac Driver in 2.6.18
Date: Fri, 22 Sep 2006 15:53:53 +0200
Message-ID: <20060922135352.GD4122@harddisk-recovery.com>
References: <4513E308.10507@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbtsai@gmail.com, John Linville <linville@tuxdriver.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:9033 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S932484AbWIVNxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 09:53:54 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <4513E308.10507@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 08:20:08AM -0500, Larry Finger wrote:
> This patch, which was originally sent to John Linville on 9/14/06,
> has been taken against 2.6.18. It changes more lines
> than would be absolutely necessary to affect the fix; however, it
> ends up with this section looking exactly like the current code (with
> pending patches) that is in wireless-2.6.

Sorry, but your patch doesn't apply cleanly against 2.6.18:

erik@arthur:~/git/linux-2.6 > patch -p1 --dry-run < ../bcm43xx-2.6.18.diff
patching file drivers/net/wireless/bcm43xx/bcm43xx_main.c
Hunk #1 FAILED at 3182.
1 out of 1 hunk FAILED -- saving rejects to file drivers/net/wireless/bcm43xx/bcm43xx_main.c.rej


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
