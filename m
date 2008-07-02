From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Setup PHYs for rtl8101/2(e) hardware
Date: Wed, 2 Jul 2008 23:50:59 +0200
Message-ID: <20080702215059.GA1378@electric-eye.fr.zoreil.com>
References: <E6FF208A16840D4EBAA31D261B15A50601415DC7@ausx3mpc121.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Mario_Limonciello@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39666 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754303AbYGBVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 17:51:12 -0400
Content-Disposition: inline
In-Reply-To: <E6FF208A16840D4EBAA31D261B15A50601415DC7@ausx3mpc121.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mario_Limonciello@Dell.com <Mario_Limonciello@Dell.com> :
[...]
> In comparing the differences with the Realtek release r8101-1.008.05-1
> of their r8101 driver, I found a handful of differences in  the startup
> procedures of the r8169 driver.  I isolated two sets of fixes that get
> rid of transient errors when loading the drivers.

(please restrain your lines to ~80 cols and Cc: Edward)

May I ask where did you got r8101-1.008.05-1 ? I only have
r8101-1.007.00 from Realtek's ftp (dated 21/04/2008).

Judging from r8101-1.007.00, I would say that your change is almost
right but that it can overlap some existing devices. This remark may
be irrelevant if there are enough differences between r8101-1.007.00
and r8101-1.008.05-1 though.

-- 
Ueimor
