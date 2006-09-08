From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Fri, 8 Sep 2006 15:23:17 +0200
Message-ID: <20060908132317.GS26916@harddisk-recovery.com>
References: <45006221.4090603@lwfinger.net> <20060908094204.GB26916@harddisk-recovery.com> <200609081145.28095.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:12344 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S1751086AbWIHNXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 09:23:19 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609081145.28095.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2006 at 11:45:27AM +0200, Michael Buesch wrote:
> The crash is fixed in wireless-2.6.
> The actual cause of the controller restart not. So at least it
> does not crash anymore.

Thanks for the information, pulled wireless-2.6 and recompiling kernel.
If this really fixes the problem, can we try to get it merged before
2.6.18 closes? I don't know if vanilla 2.6.18-rc6 locks up on other
hardware as well, but if it does it would be a major regression against
2.6.17.


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
