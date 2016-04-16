From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Kill the REG_READ and REG_WRITE macros
Date: Sat, 16 Apr 2016 19:23:58 -0400 (EDT)
Message-ID: <20160416.192358.344801720781346920.davem@davemloft.net>
References: <1460670432-23801-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbcDPXYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 19:24:00 -0400
In-Reply-To: <1460670432-23801-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 14 Apr 2016 23:47:12 +0200

> These macros hide a ds variable and a return statement on error, which
> can lead to locking issues. Kill them off.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
