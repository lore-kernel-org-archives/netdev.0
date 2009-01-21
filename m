From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: allow type check of devdbg arguments in
 non-debug build
Date: Wed, 21 Jan 2009 12:35:57 -0800 (PST)
Message-ID: <20090121.123557.30650362.davem@davemloft.net>
References: <1232552707-4130-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david-b@pacbell.net
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbZAUUfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 15:35:55 -0500
In-Reply-To: <1232552707-4130-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed, 21 Jan 2009 15:45:07 +0000

> Improve usbnet's devdbg to always type-check diagnostic arguments,
> like dev_dbg (device.h).  This makes no change to the resulting size of
> usbnet modules.
> 
> This patch also removes an #ifdef DEBUG directive from rndis_wlan so
> it's devdbg statements are always type-checked at compile time.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

Applied, thanks Steve.
