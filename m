From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] enic: allow adaptive coalesce setting for
 msi/legacy intr
Date: Mon, 20 Jul 2015 12:39:50 -0700 (PDT)
Message-ID: <20150720.123950.36893082016260196.davem@davemloft.net>
References: <1436954680-10248-1-git-send-email-_govind@gmx.com>
	<1436954680-10248-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754048AbbGTTjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:39:51 -0400
In-Reply-To: <1436954680-10248-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 15 Jul 2015 15:34:40 +0530

> * Allow setting of adaptive coalescing setting for all types of interrupt.
> 
> * In msi & legacy intr, we use single interrupt for rx & tx. In this case
>   tx_coalesce_usecs is invalid. We should use only rx_coalesce_usecs.
>   Do not display tx_coal values for msi/intx. And do not allow user to set
>   this as well.
> 
> * Driver supports only tx/rx_coalesce_usec and adaptive coalesce settings.
>   For other values, driver does not return error. So ethtool succeeds for
>   unsupported values. Introduce enic_coalesce_valid() function to validate
>   the coalescing values.
> 
> * If user requests for coalesce value greater than what adaptor supports,
>   driver uses the max value. We should at least log this.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
