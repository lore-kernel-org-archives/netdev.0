From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][BNX2X] .h files rewrite
Date: Mon, 29 Oct 2007 01:39:31 -0700 (PDT)
Message-ID: <20071029.013931.203090879.davem@davemloft.net>
References: <1193602670.4836.25.camel@eliezer>
	<1193602875.4836.28.camel@eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jeff@garzik.org, netdev@vger.kernel.org,
	masbock@us.ibm.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbXJ2Ijd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 04:39:33 -0400
In-Reply-To: <1193602875.4836.28.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Sun, 28 Oct 2007 22:21:14 +0200

Overall things look significantly better, thanks a lot!

However, there is still one set of magic constants in here
which I hope you can clear up:

> +static const struct raw_op init_ops[] = {
> +#define PRS_COMMON_START        0
> +	{OP_WR, PRS_REG_INC_VALUE, 0xf},
> +	{OP_WR, PRS_REG_EVENT_ID_1, 0x45},
> +	{OP_WR, PRS_REG_EVENT_ID_2, 0x84},
> +	{OP_WR, PRS_REG_EVENT_ID_3, 0x6},
> +	{OP_WR, PRS_REG_NO_MATCH_EVENT_ID, 0x4},
> +	{OP_WR, PRS_REG_CM_HDR_TYPE_0, 0x0},
> +	{OP_WR, PRS_REG_CM_HDR_TYPE_1, 0x12170000},
> +	{OP_WR, PRS_REG_CM_HDR_TYPE_2, 0x22170000},
> +	{OP_WR, PRS_REG_CM_HDR_TYPE_3, 0x32170000},
> +	{OP_ZR, PRS_REG_CM_HDR_TYPE_4, 0x5},
> +	{OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_1, 0x12150000},
> +	{OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_2, 0x22150000},
> +	{OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_3, 0x32150000},
> +	{OP_ZR, PRS_REG_CM_HDR_LOOPBACK_TYPE_4, 0x4},
 etc. etc.

Take care.
