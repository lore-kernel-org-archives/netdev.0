From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169 : MAC address change fix for the 8168e-vl.
Date: Tue, 02 Aug 2011 17:09:09 -0700 (PDT)
Message-ID: <20110802.170909.805403275265071509.davem@davemloft.net>
References: <20110802135343.GA13908@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab1HCAJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 20:09:20 -0400
In-Reply-To: <20110802135343.GA13908@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 2 Aug 2011 15:53:43 +0200

> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=39252
> 
> Hayes suggested that the usual MAC{0, 4} register writes be completed
> with writes to extended GigaMAC registers :
> - 0xe0 .. 0xe5
> - 0xf2 .. 0xf7
> 
> Registers 0xf0 and 0xf1 should be set to 0.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks.
