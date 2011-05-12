From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 15/15] ehea: Remove unused tcp_end field in send WQ
Date: Wed, 11 May 2011 19:31:13 -0700
Message-ID: <1305167473.6124.11.camel@Joe-Laptop>
References: <20110512005213.897432612@samba.org>
	 <20110512005623.854973618@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1511 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab1ELCbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 22:31:14 -0400
In-Reply-To: <20110512005623.854973618@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> plain text document attachment (ehea_22.patch)
> The tcp_end field is not actually used by the hardware, so there
> is no need to set it. 
> +++ linux-net/drivers/net/ehea/ehea_qmr.h	2011-05-12 07:48:06.380382084 +1000
> @@ -106,7 +106,7 @@ struct ehea_swqe {
>  	u8 immediate_data_length;
>  	u8 tcp_offset;
>  	u8 reserved2;
> -	u16 tcp_end;
> +	u16 reserved2b;
>  	u8 wrap_tag;
>  	u8 descriptors;		/* number of valid descriptors in WQE */
>  	u16 reserved3;

struct ehea_swqe isn't __packed.  Shouldn't it be?


