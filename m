From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] sfc: QT202x: Reset before reading PHY id
Date: Sat, 28 Nov 2009 23:59:08 -0800 (PST)
Message-ID: <20091128.235908.01032771.davem@davemloft.net>
References: <1259422469.3709.3.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbZK2H7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 02:59:02 -0500
In-Reply-To: <1259422469.3709.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:34:29 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Reading standard registers on the QT2025C before its firmware has
> booted may cause the boot process to fail.  Therefore, follow the
> recommended reset sequence before reading its id registers.  Either
> order works for the QT2022C2, so don't differentiate.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
