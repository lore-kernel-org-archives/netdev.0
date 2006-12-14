From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the
 latest API draft.
Date: Wed, 13 Dec 2006 16:35:54 -0800 (PST)
Message-ID: <20061213.163554.63998920.davem@davemloft.net>
References: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751872AbWLNAfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:35:55 -0500
To: sri@us.ibm.com
In-Reply-To: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 13 Dec 2006 12:44:52 -0800

> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index 35108fe..d4f8656 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -180,7 +180,7 @@ typedef enum {
>  	SCTP_PARAM_ERR_CAUSE		= __constant_htons(0xc003),
>  	SCTP_PARAM_SET_PRIMARY		= __constant_htons(0xc004),
>  	SCTP_PARAM_SUCCESS_REPORT	= __constant_htons(0xc005),
> -	SCTP_PARAM_ADAPTION_LAYER_IND   = __constant_htons(0xc006),
> +	SCTP_PARAM_ADAPTATION_LAYER_IND = __constant_htons(0xc006),
>  
>  } sctp_param_t; /* enum */
>  

I don't care what the API draft says, you will break existing
userspace applications by changing this define.

Please keep around a compatible define, and then add the new one.

Thanks.
