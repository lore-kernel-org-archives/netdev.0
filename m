From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] r8169: allow true forced mode setting
Date: Tue, 19 May 2009 14:32:58 -0700 (PDT)
Message-ID: <20090519.143258.172883145.davem@davemloft.net>
References: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
	<20090518.192500.266612299.davem@davemloft.net>
	<20090519204648.GB6346@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vsteenhoute@novell.com, jdelvare@suse.de, tbm@cyrius.com,
	xose.vazquez@gmail.com, ivecera@redhat.com,
	edward_hsu@realtek.com.tw, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752318AbZESVdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:33:00 -0400
In-Reply-To: <20090519204648.GB6346@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 19 May 2009 22:46:48 +0200

> Due to mostly historic reasons, including a lack of reliability
> of the link handling (especially with the older 8169), the
> current r8169 driver emulates forced mode setting by limiting
> the advertised modes.
> 
> With this change the driver allows real 10/100 forced mode
> settings on the 8169 and 8101/8102.
> 
> Original idea by Vincent Steenhoute. The RTL_GIGA_MAC_VER_03
> tweak was extracted from Realtek's r8169 v6.010.00 driver.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Jean Delvare <jdelvare@suse.de>

Applied to net-next-2.6, thanks!
