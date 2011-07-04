From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 8139too: Initial necessary vlan_features to
 support vlan
Date: Sun, 03 Jul 2011 19:54:23 -0700 (PDT)
Message-ID: <20110703.195423.1809799333507901972.davem@davemloft.net>
References: <4E0ED194.2030103@cn.fujitsu.com>
	<20110702095138.GA4736@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org,
	adobriyan@gmail.com, tj@kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab1GDDAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 23:00:53 -0400
In-Reply-To: <20110702095138.GA4736@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 2 Jul 2011 11:51:38 +0200

> Shan Wei <shanwei@cn.fujitsu.com> :
>> Offload setting of vlan device requires
>> vlan_features to be initialed.
> [...]
>> @@ -993,6 +993,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
>>  	 * features
>>  	 */
>>  	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
>> +	dev->vlan_features = dev->features;
> 
>         /* note: the hardware is not capable of sg/csum/highdma, however
>          * through the use of skb_copy_and_csum_dev we enable these
>          * features
>          */
> 
> The commit message is a bit misleading wrt hardware capabilities but the
> patch makes sense.
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
