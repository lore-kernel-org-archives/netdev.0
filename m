From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/8] amd-xgbe: AMD XGBE driver updates
 2014-11-20
Date: Fri, 21 Nov 2014 15:20:45 -0500 (EST)
Message-ID: <20141121.152045.54354762944678102.davem@davemloft.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbaKUUUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:20:48 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 20 Nov 2014 11:03:20 -0600

> The following series of patches includes functional updates to the
> driver as well as some trivial changes.
> 
> - Add a read memory barrier in the Tx and Rx path after checking the
>   descriptor ownership bit
> - Wait for the Tx engine to stop/suspend before issuing a stop command
> - Implement a smatch tool suggestion to simplify an if statement
> - Separate out Tx and Rx ring data fields into their own structures
> - Add BQL support
> - Remove an unused variable
> - Change Tx coalescing support to operate on packet basis instead of
>   a descriptor basis
> - Add support for the skb->xmit_more flag
> 
> This patch series is based on net-next.

Lots of great stuff in here, series applied, thanks Tom.
