From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Fix deadlock by double lock
Date: Sun, 07 Jun 2015 12:19:35 -0700 (PDT)
Message-ID: <20150607.121935.635064695534051812.davem@davemloft.net>
References: <1433459409-16488-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbFGTTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 15:19:47 -0400
In-Reply-To: <1433459409-16488-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri,  5 Jun 2015 01:10:09 +0200

> ethtool -S on a DSA interface can deadlock for some switches because
> the same lock is taken twice. Use the register read function which
> expects the lock to be already held.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 31888234b736 ("net: dsa: mv88e6xxx: Replace stats mutex with SMI mutex")

Applied, thanks.
