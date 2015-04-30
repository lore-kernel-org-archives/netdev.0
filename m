From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 4/4] ibmveth: Add support for Large Receive
 Offload
Date: Thu, 30 Apr 2015 16:34:24 -0400 (EDT)
Message-ID: <20150430.163424.1205270533218369606.davem@davemloft.net>
References: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
	<1430342747-16774-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	brking@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbD3Ue1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:34:27 -0400
In-Reply-To: <1430342747-16774-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 29 Apr 2015 16:25:47 -0500

> Enables receiving large packets from other LPARs. These packets
> have a -1 IP header checksum, so we must recalculate to have
> a valid checksum.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
> v3:
>  -Removed code setting network and transport headers
>  -get IP header from skb data
>   Thanks again to Eric Dumazet
> 
> v2:
>  -Included statistics that were previously in a separate patch
>  -Zeroed the IP header checksum before calling ip_fast_csum
>   Thanks to Eric Dumazet.

Applied.
