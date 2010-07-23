From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] be2net: supress printing error when mac
 query fails for VF
Date: Fri, 23 Jul 2010 12:38:38 -0700 (PDT)
Message-ID: <20100723.123838.189715608.davem@davemloft.net>
References: <20100723120008.GA24995@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751832Ab0GWTiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 15:38:21 -0400
In-Reply-To: <20100723120008.GA24995@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 23 Jul 2010 17:30:24 +0530

> -	} else if (compl_status != MCC_STATUS_NOT_SUPPORTED) {
> +	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
> +			(compl->tag0 != OPCODE_COMMON_NTWK_MAC_QUERY)) {

I'll fix up this formatting when applying this patch but please be mindful
of this in the future, it should look like:


	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
		   (compl->tag0 != OPCODE_COMMON_NTWK_MAC_QUERY)) {
