From: David Miller <davem@davemloft.net>
Subject: Re: [Resend v2 PATCH 3/3] TCP: Remove redundant checks when
 setting eff_sacks
Date: Sat, 19 Jul 2008 00:09:31 -0700 (PDT)
Message-ID: <20080719.000931.85660174.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069023@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbYGSHJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:09:32 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069023@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 17 Jul 2008 16:08:10 -0700

> Remove redundant checks when setting eff_sacks and make the number of SACKs a
> compile time constant. Now that the options code knows how many SACK blocks can
> fit in the header, we don't need to have the SACK code guessing at it.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Also applied, thanks Adam.
