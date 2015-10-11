From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: RE: [PATCH net-next] bnxt_en: New Broadcom ethernet driver.
Date: Sun, 11 Oct 2015 06:54:40 +0000
Message-ID: <87B4DDAD5EAFA041BDC28F314593782D09001A2C@avmb3.qlogic.org>
References: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:19238 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751332AbbJKGyo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2015 02:54:44 -0400
In-Reply-To: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Michael Chan
> Sent: Saturday, October 10, 2015 2:39 PM
> To: David Miller <davem@davemloft.net>
> Cc: netdev <netdev@vger.kernel.org>
> Subject: [PATCH net-next] bnxt_en: New Broadcom ethernet driver.
> 
> +config BNXT
> +	tristate "Broadcom NetXtreme-C/E support"
> +	depends on PCI
> +	select FW_LOADER
> +	select LIBCRC32C
> +	---help---
> +	  This driver supports Broadcom NetXtremeII 10/25/40/50 gigabit
> +	  Ethernet cards.  To compile this driver as a module, choose M here:
> +	  the module will be called bnx2x.  This is recommended.
Should be bnxt
