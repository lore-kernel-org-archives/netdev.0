From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] qlcnic: bug fixes
Date: Tue, 28 Jan 2014 12:00:22 -0800 (PST)
Message-ID: <20140128.120022.990469973055578396.davem@davemloft.net>
References: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790AbaA1UAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 15:00:25 -0500
In-Reply-To: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 28 Jan 2014 11:55:26 -0500

> The patch series contains following bug fixes
> 
> o Bound checks for number of receive descriptors and number of recieve rings.
>   Both of these have off-by-one errors.
> o Vlan list was getting re-initialized in case of adapter reset.
> o Tx queue was timing out because of missing start queue for a corresponding
>   netif_tx_disable.
> o Loopback test failed because driver was not setting linkup variable
>   while handling link events.
>  
> Please apply to net.

Series applied, thanks.
