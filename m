From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [BNX2]: Update RV2P firmware for 5709.
Date: Fri, 02 May 2008 16:58:56 -0700 (PDT)
Message-ID: <20080502.165856.135271135.davem@davemloft.net>
References: <1209595930.7941.64.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935580AbYEBX64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:58:56 -0400
In-Reply-To: <1209595930.7941.64.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Apr 2008 15:52:10 -0700

> [BNX2]: Update RV2P firmware for 5709.
> 
> The new RV2P firmware fixes 2 issues:
> 
> 1. The jumbo rx buffer page size is now configurable and set to the proper
> PAGE_SIZE.  Before, it was assumed to be always 4K.
> 
> 2. Driver sometimes would crash when receiving jumbo packets mixed with
> firmware management packets.  This was caused by the old firmware DMA'ing
> to the wrong address.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
