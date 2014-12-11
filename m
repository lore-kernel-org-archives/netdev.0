From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net] be2net: Export tunnel offloads only when a VxLAN
 tunnel is created
Date: Thu, 11 Dec 2014 07:24:38 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C68D24ADD@CMEXMB1.ad.emulex.com>
References: <1418205364-28979-1-git-send-email-sathya.perla@emulex.com>
 <20141210.145338.683039710260795306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:42720 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbaLKHZE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 02:25:04 -0500
In-Reply-To: <20141210.145338.683039710260795306.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Sathya Perla <sathya.perla@emulex.com>
> Date: Wed, 10 Dec 2014 04:56:04 -0500
> 
> > +	netdev->hw_enc_features |= (NETIF_F_IP_CSUM |
> NETIF_F_IPV6_CSUM |
> > +	    NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL);
> 
> Please indent this properly:
> 
> 	netdev->hw_enc_features |= (NETIF_F_IP_CSUM |
> NETIF_F_IPV6_CSUM |
> 				    NETIF_F_TSO | NETIF_F_TSO6 |
> NETIF_F_GSO_UDP_TUNNEL);

Oops, checkpatch didn't seem to catch this...will fix it up and send out a v2 right away...
thanks!
