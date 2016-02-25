From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Propagate MAC address changes to VLANs
Date: Thu, 25 Feb 2016 16:15:42 -0500 (EST)
Message-ID: <20160225.161542.1646814580366436236.davem@davemloft.net>
References: <56CCC77F.5050401@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbcBYVPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:15:44 -0500
In-Reply-To: <56CCC77F.5050401@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Tue, 23 Feb 2016 20:56:31 +0000

> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -293,15 +293,15 @@ static void vlan_sync_address(struct net
> 
>      /* vlan address was different from the old address and is equal to
>       * the new address */
> -    if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> +    if ((vlandev->flags & IFF_UP) &&
> +        !ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&

This patch is corrupted by your email client.

Please read Documentation/email-clients.txt, fix your setup, and email a
test patch to yourself.

Only resubmit this patch to the list once you are able to successfully
apply the patch in that test email.
