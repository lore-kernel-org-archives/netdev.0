From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: Enable StripCRC feature
Date: Thu, 11 Dec 2008 00:18:03 +0900 (JST)
Message-ID: <20081211.001803.05599238.anemo@mba.ocn.ne.jp>
References: <20081210.001506.72707763.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:64946 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010AbYLJPR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 10:17:59 -0500
In-Reply-To: <20081210.001506.72707763.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Dec 2008 00:15:06 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> The chip can strip CRC automatically on receiving.  Enable it.
> 
> Also fix potential RX_BUF_SIZE calculation bug which was obscured by
> alignment.  And use proper symbols (NET_IP_ALIGN, ETH_FCS_LEN, etc.)
> instead of magic numbers.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Sorry, this patch was broken (backslash missing).  I will send correct
patch soon.
---
Atsushi Nemoto
