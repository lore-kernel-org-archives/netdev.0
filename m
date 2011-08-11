From: Panduranga <x0125717@ti.com>
Subject: Re: [PATCH 0/1] OMAP: wlan : To fix wlan issue with kernel 3.0
Date: Thu, 11 Aug 2011 12:45:07 +0530
Message-ID: <606B2926D61D49379AEF49D407C6C912@MINX0125717>
References: <1311950476-2452-1-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <ohad@wizery.com>, "Gabay, Benzy" <benzyg@ti.com>,
	"Gurumath, Pradeep" <pradeepgurumath@ti.com>,
	"Mahaveer, Vishal" <vishalm@ti.com>,
	"Boudet, Xavier" <x-boudet@ti.com>,
	"Jain, Naveen" <naveen_jain@ti.com>,
	"Halli, Manjunatha" <manjunatha_halli@ti.com>,
	"Mallireddy, Panduranga" <panduranga_mallireddy@ti.com>,
	"Coelho, Luciano" <coelho@ti.com>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-mmc@vger.kernel.org>
To: <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:46143 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab1HKHPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 03:15:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tony,

Can you merge this patch series to Kernel 3.1.
It fixes the WLAN issue on Panda board, reported in Kernel 3.0

Regards,
Pandu.

----- Original Message ----- 
From: "Mallireddy, Panduranga" <panduranga_mallireddy@ti.com>
To: "Coelho, Luciano" <coelho@ti.com>; <netdev@vger.kernel.org>; 
<linux-omap@vger.kernel.org>; <linux-mmc@vger.kernel.org>
Cc: <ohad@wizery.com>; "Gabay, Benzy" <benzyg@ti.com>; "Gurumath, Pradeep" 
<pradeepgurumath@ti.com>; "Mahaveer, Vishal" <vishalm@ti.com>; "Boudet, 
Xavier" <x-boudet@ti.com>; "Jain, Naveen" <naveen_jain@ti.com>; "Halli, 
Manjunatha" <manjunatha_halli@ti.com>; "Mallireddy, Panduranga" 
<panduranga_mallireddy@ti.com>
Sent: Friday, July 29, 2011 8:11 PM
Subject: [PATCH 0/1] OMAP: wlan : To fix wlan issue with kernel 3.0


From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>

Error reported for wl12xx driver with Kernel 3.0 is
[    0.181457] error setting wl12xx data

FIX:
For regulator omap4_clk32k used by wlan, set .constraints.always_on to 1

Panduranga Mallireddy (1):
  OMAP: wlan: Set the WLAN Regulator to be always on

 arch/arm/mach-omap2/twl-common.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


