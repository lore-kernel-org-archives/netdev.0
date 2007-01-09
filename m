From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2 3/4]: Fix bug in bnx2_nvram_write().
Date: Mon, 08 Jan 2007 19:56:55 -0800 (PST)
Message-ID: <20070108.195655.107291007.davem@davemloft.net>
References: <1168300608.4430.9.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750977AbXAID4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 22:56:55 -0500
To: mchan@broadcom.com
In-Reply-To: <1168300608.4430.9.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 08 Jan 2007 15:56:48 -0800

> [BNX2]: Fix bug in bnx2_nvram_write().
> 
> The bug was a bogus pointer being passed to kfree().  The pointer was
> incremented in the write loop and then passed to kfree().
> 
> The fix is to use align_buf to save the original address.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
