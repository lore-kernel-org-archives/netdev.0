From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tg3: WOL fixes
Date: Sun, 21 Dec 2008 20:22:05 -0800 (PST)
Message-ID: <20081221.202205.212196245.davem@davemloft.net>
References: <1229717357.5496@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbYLVEWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:22:03 -0500
In-Reply-To: <1229717357.5496@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 17 Dec 2008 16:33:37 -0800

> The first hunk of this patch inverts a flag that was accidentally
> toggled as part of commit 0a459aac9d151c2e36ec65723b9b845b24c5cbc3.
> 
> The second hunk of the patch removes the call to
> device_may_wakeup() in the 5906 config detection path.  At the
> point of the call, the driver shouldn't be querying for WOL
> capability.  It should be detecting and setting it.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
