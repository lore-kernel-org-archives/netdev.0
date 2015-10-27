From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fsl: expands dependencies of NET_VENDOR_FREESCALE
Date: Tue, 27 Oct 2015 07:04:58 -0700 (PDT)
Message-ID: <20151027.070458.1404589365170744859.davem@davemloft.net>
References: <1445849391-422-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com,
	stuart.yoder@freescale.com, bhamciu1@freescale.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbbJ0NsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 09:48:20 -0400
In-Reply-To: <1445849391-422-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Mon, 26 Oct 2015 16:49:51 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Freescale hosts some ARMv8 based SoCs, and a generic convention
> ARCH_LAYERSCAPE is used to cover such SoCs. Adding ARCH_LAYERSCAPE
> to dependencies of NET_VENDOR_FREESCALE to support networking on those
> SoCs.
> 
> The patch to add ARCH_LAYERSCAPE can be viewed at:
> http://www.spinics.net/lists/arm-kernel/msg455583.html
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Since ARCH_LAYERSCAPE doesn't exist in my tree, it is best to
merge this via the appropriate ARM tree.

Acked-by: David S. Miller <davem@davemloft.net>
