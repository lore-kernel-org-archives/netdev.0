From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] r8169: allow true forced mode setting
Date: Mon, 18 May 2009 19:25:00 -0700 (PDT)
Message-ID: <20090518.192500.266612299.davem@davemloft.net>
References: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vsteenhoute@novell.com, jdelvare@suse.de, tbm@cyrius.com,
	xose.vazquez@gmail.com, ivecera@redhat.com,
	edward_hsu@realtek.com.tw, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34963
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752925AbZESCZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:25:02 -0400
In-Reply-To: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 14 May 2009 23:46:05 +0200

> Due to mostly historic reasons, including a lack of reliability
> of the link handling (especially with the older 8169), the
> current r8169 driver emulates forced mode setting by limiting
> the advertised modes.
> 
> With this change the driver allows real 10/100 forced mode
> settings on the 8169 and 8101/8102.
> 
> Original idea by Vincent Steenhoute. The RTL_GIGA_MAC_VER_03
> tweak was extracted from Realtek's v6.009.00 driver.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Jean Delvare <jdelvare@suse.de>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>

Francois, you say later in this thread that you have a new
version of this patch coming.  Is that coming soon?

I'm holding off on the first one until you submit the new
version of this second one.

Thanks.
