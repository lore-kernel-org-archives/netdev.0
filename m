From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: check trunc_len in XFRMA_ALG_AUTH_TRUNC
Date: Tue, 11 Jan 2011 14:04:58 -0800 (PST)
Message-ID: <20110111.140458.228951886.davem@davemloft.net>
References: <4D2C9B9C.9020800@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932144Ab1AKWE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 17:04:26 -0500
In-Reply-To: <4D2C9B9C.9020800@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 11 Jan 2011 19:04:12 +0100

>>From 48dd29c69f150fc55bf3a477b9365d1575a9cfbe Mon Sep 17 00:00:00 2001
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 11 Jan 2011 13:23:51 -0500
> Subject: [PATCH] xfrm: check trunc_len in XFRMA_ALG_AUTH_TRUNC
> 
> Maximum trunc length is defined by MAX_AH_AUTH_LEN (in bytes)
> and need to be checked when this value is set (in bits) by
> the user. In ah4.c and ah6.c a BUG_ON() checks this condiftion.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
