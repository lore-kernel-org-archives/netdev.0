From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: ezchip: adapt driver to little endian architecture
Date: Fri, 26 Feb 2016 21:10:31 +0100
Message-ID: <24793363.yg41IbJKTo@wuerfel>
References: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>
To: Lada Trimasova <Lada.Trimasova@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:56615 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165AbcBZUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:10:38 -0500
In-Reply-To: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 26 February 2016 22:05:09 Lada Trimasova wrote:
>                 for (i = 0; i < len; i++, reg++) {
>                         u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
> +                       buf = be32_to_cpu(buf);
>                         put_unaligned(buf, reg);
>                 }

I think most of the changes can make use of the put_unaligned_be32()
etc helpers that might also be more efficient.

	Arnd
