From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 2/5] net: ep93xx_eth: pass struct device to DMA API
 functions
Date: Thu, 9 Jun 2011 15:41:58 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B8608@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <c0ddfc297e0ea1e64e58cedd6552c6b2e52c5fe8.1307040443.git.mika.westerberg@iki.fi>
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
Received: from mail209.messagelabs.com ([216.82.255.3]:9862 "EHLO
	mail209.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab1FIUmE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:42:04 -0400
In-Reply-To: <c0ddfc297e0ea1e64e58cedd6552c6b2e52c5fe8.1307040443.git.mika.westerberg@iki.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
>
> We shouldn't use NULL for any DMA API functions, unless we are dealing with
> ISA or EISA device. So pass correct struct dev pointer to these functions.
>
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Looks right to me..

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
