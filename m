From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: phy_device, fix lock imbalance
Date: Tue, 14 Jul 2009 12:27:17 -0700 (PDT)
Message-ID: <20090714.122717.167640290.davem@davemloft.net>
References: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756094AbZGNT1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:27:13 -0400
In-Reply-To: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Mon, 13 Jul 2009 23:23:39 +0200

> Don't forget to unlock a mutex in phy_scan_fixups on a fail path.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied.
