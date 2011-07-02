From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: 8139too: Initial necessary vlan_features to support vlan
Date: Sat, 2 Jul 2011 11:51:38 +0200
Message-ID: <20110702095138.GA4736@electric-eye.fr.zoreil.com>
References: <4E0ED194.2030103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, tj@kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48712 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab1GBKIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2011 06:08:11 -0400
Content-Disposition: inline
In-Reply-To: <4E0ED194.2030103@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei <shanwei@cn.fujitsu.com> :
> Offload setting of vlan device requires
> vlan_features to be initialed.
[...]
> @@ -993,6 +993,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
>  	 * features
>  	 */
>  	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
> +	dev->vlan_features = dev->features;

        /* note: the hardware is not capable of sg/csum/highdma, however
         * through the use of skb_copy_and_csum_dev we enable these
         * features
         */

The commit message is a bit misleading wrt hardware capabilities but the
patch makes sense.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

--
Ueimor
