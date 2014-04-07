From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH net 1/2] sxgbe: fix duplicate #include headers
Date: Mon, 07 Apr 2014 18:46:49 +0900
Message-ID: <038301cf5246$4c51eea0$e4f5cbe0$%an@samsung.com>
References: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
 <1396679341-23502-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Girish K S' <ks.giri@samsung.com>,
	'Siva Reddy Kallam' <siva.kallam@samsung.com>,
	'Vipul Pandya' <vipul.pandya@samsung.com>
To: 'Jean Sacren' <sakiwit@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:9309 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbaDGJqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 05:46:51 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N3N00B7RN62OP30@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 07 Apr 2014 18:46:50 +0900 (KST)
In-reply-to: <1396679341-23502-2-git-send-email-sakiwit@gmail.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Sacren wrote:
> 
> The commit 1edb9ca69e8a ("net: sxgbe: add basic framework for
> Samsung 10Gb ethernet driver") added support for Samsung 10Gb
> ethernet driver(sxgbe) with a minor issue of including linux/io.h
> header twice in sxgbe_dma.c file. Fix the duplicate #include by
> deleting the top one so that all the rest good #include headers
> would be preserved in the alphabetical order.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Byungho An <bh74.an@samsung.com>

Acked-by: Byungho An <bh74.an@samsung.com>

Thanks,
Byungho

> Cc: Girish K S <ks.giri@samsung.com>
> Cc: Siva Reddy Kallam <siva.kallam@samsung.com>
> Cc: Vipul Pandya <vipul.pandya@samsung.com>
> ---
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
> b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
> index 28f89c41d0cd..4d989ff6c978 100644
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
> +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
> @@ -9,7 +9,6 @@
>   * it under the terms of the GNU General Public License version 2 as
>   * published by the Free Software Foundation.
>   */
> -#include <linux/io.h>
>  #include <linux/delay.h>
>  #include <linux/export.h>
>  #include <linux/io.h>
