From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][INET]: Fix accidentally broken inet(6)_hash_connect's
 port offset calculations.
Date: Tue, 05 Feb 2008 03:14:52 -0800 (PST)
Message-ID: <20080205.031452.140690606.davem@davemloft.net>
References: <47A6C87D.7060304@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35649
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbYBELOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:14:24 -0500
In-Reply-To: <47A6C87D.7060304@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 04 Feb 2008 11:10:37 +0300

> The port offset calculations depend on the protocol family, but,
> as Adrian noticed, I broke this logic with the commit
> 
> 	5ee31fc1ecdcbc234c8c56dcacef87c8e09909d8
> 	[INET]: Consolidate inet(6)_hash_connect.
> 
> Return this logic back, by passing the port offset directly into 
> the consolidated function.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Noticed-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks.
