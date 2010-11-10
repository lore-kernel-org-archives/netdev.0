From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Tue, 09 Nov 2010 21:28:38 -0800 (PST)
Message-ID: <20101109.212838.193698340.davem@davemloft.net>
References: <1289341724.7380.13.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750952Ab0KJF2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 00:28:14 -0500
In-Reply-To: <1289341724.7380.13.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Tue, 09 Nov 2010 17:28:44 -0500

> The "mem" array used as scratch space for socket filters is not
> initialized, allowing unprivileged users to leak kernel stack bytes.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

Prove it.
