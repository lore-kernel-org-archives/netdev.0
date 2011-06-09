From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 3/5] net: ep93xx_eth: allocate buffers using kmalloc()
Date: Thu, 9 Jun 2011 15:53:01 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B8616@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <7b20107efa24e0a0c956663ddc70b2189f64c04b.1307040443.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>
To: Mika Westerberg <mika.westerberg@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail131.messagelabs.com ([216.82.242.99]:55602 "EHLO
	mail131.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab1FIUxI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:53:08 -0400
In-Reply-To: <7b20107efa24e0a0c956663ddc70b2189f64c04b.1307040443.git.mika.westerberg@iki.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
>
> We can use simply kmalloc() to allocate the buffers. This also simplifies the
> code and allows us to perform DMA sync operations more easily.
>
> Memory is allocated with only GFP_KERNEL since there are no DMA allocation
> restrictions on this platform.
>
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Looks ok to me.

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
