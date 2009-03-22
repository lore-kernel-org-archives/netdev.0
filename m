From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] sfc: Pad packets to 33 bytes to prevent TX packet
 parser lockup
Date: Sat, 21 Mar 2009 19:09:42 -0700 (PDT)
Message-ID: <20090321.190942.86384309.davem@davemloft.net>
References: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbZCVCJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:09:54 -0400
In-Reply-To: <1237591540.3217.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 20 Mar 2009 23:25:39 +0000

> The packet parser used in the TX data path for locating checksum
> fields can lose synchronisation with the TX queue manager when
> handling packets that look like IPv4 but are too short (17-32 bytes).
> Work around this by padding to 33 bytes.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
