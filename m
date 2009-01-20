From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix multicast filter programming
Date: Mon, 19 Jan 2009 17:17:24 -0800 (PST)
Message-ID: <20090119.171724.169700515.davem@davemloft.net>
References: <20090119095813.GF17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	matt@genesi-usa.com, paubert@iram.es
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752374AbZATBR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:17:26 -0500
In-Reply-To: <20090119095813.GF17124@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 19 Jan 2009 10:58:13 +0100

> Commit 66e63ffbc04706568d8789cbb00eaa8ddbcae648 ("mv643xx_eth:
> implement ->set_rx_mode()") cleaned up mv643xx_eth's multicast filter
> programming, but broke it as well.
> 
> The non-special multicast filter table (for multicast addresses that
> are not of the form 01:00:5e:00:00:xx) consists of 256 hash table
> buckets organised as 64 32-bit words, where the 'accept' bits are
> in the LSB of each byte, so in bits 24 16 8 0 of each 32-bit word.
> The old code got this right, but the referenced commit broke this by
> using bits 3 2 1 0 instead.  This commit fixes this up.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
