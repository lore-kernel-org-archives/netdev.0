From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] sunvnet: set queue mapping when doing packet copies
Date: Wed, 28 Jan 2015 11:48:55 -0500
Message-ID: <20150128164855.GD12529@oracle.com>
References: <54C90AED.7040404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:45995 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbbA2B2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:28:45 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t0SGmwB4020537
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 16:48:58 GMT
Content-Disposition: inline
In-Reply-To: <54C90AED.7040404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/28/15 11:14), David L Stevens wrote:
> 
>  This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
>  queue mapping when a packet copy was required. This results in using the
>  wrong queue index for stops/starts, hung tx queues and watchdog timeouts
>  under heavy load.

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
