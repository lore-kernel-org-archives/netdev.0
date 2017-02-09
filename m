From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v2 net-next] enic: add vxlan offload support
Date: Thu, 09 Feb 2017 17:24:46 -0500 (EST)
Message-ID: <20170209.172446.599627719938686514.davem@davemloft.net>
References: <20170209004309.1225-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753643AbdBIWYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:24:53 -0500
In-Reply-To: <20170209004309.1225-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Wed,  8 Feb 2017 16:43:06 -0800

> This series adds vxlan offload support for enic driver. The first
> patch adds vxlan devcmd for configuring vxland offload parameters.
> Second patch adds ndo_udp_tunnel_add/del and offload on rx path.
> There are to modes in which fw supports vxlan offload.
> 
> mode 0: fcoe bit is set for encapsulated packet. fcoe_fc_crc_ok is set
> if checksum of csum is ok. This bit is or of ip_csum_ok and
> tcp_udp_csum_ok
> 
> mode 2: BIT(0) in rss_hash is set if it is encapsulated packet.
>         BIT(1) is set if outer_ip_csum_ok/
>         BIT(2) is set if outer_tcp_csum_ok
> 
> Some hw supports only mode 0, some support mode 0 and 2. Driver gets
> the supported modes bitmap using get_supported_feature_ver devcmd
> and selects the highest mode both driver and fw supports.
> 
> Third patch adds offload support on tx path by adding
> enic_features_check().
> 
> v2: Order local variable declarations from longest to shortest line,
>     on all three patches.

Series applied to net-next, thanks.
