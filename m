From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix skb_truesize_check() assertion
Date: Sat, 10 Nov 2007 21:53:45 -0800 (PST)
Message-ID: <20071110.215345.02573115.davem@davemloft.net>
References: <20071108165919.14014.56630.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750711AbXKKFxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:53:46 -0500
In-Reply-To: <20071108165919.14014.56630.stgit@manray.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 08 Nov 2007 11:59:19 -0500

> The intent of the assertion in skb_truesize_check() is to check
> for skb->truesize being decremented too much by other code,
> resulting in a wraparound below zero.
> 
> The type of the right side of the comparison causes the compiler to
> promote the left side to an unsigned type, despite the presence of an
> explicit type cast.  This defeats the check for negativity.
> 
> Ensure both sides of the comparison are a signed type to prevent the
> implicit type conversion.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Applied, thanks Chuck.
