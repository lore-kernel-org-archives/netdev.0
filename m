From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3] net: dummy: Introduce dummy virtual
 functions
Date: Wed, 23 Nov 2016 05:26:28 -0800
Message-ID: <1479907588.8455.484.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161123124125.3374-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Sabrina Dubroca <sd@queasysnail.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33036 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938426AbcKWN0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 08:26:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so726164pfv.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 05:26:30 -0800 (PST)
In-Reply-To: <20161123124125.3374-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-23 at 13:41 +0100, Phil Sutter wrote:

> +struct vf_data_storage {
> +	unsigned char vf_mac[ETH_ALEN];
> +	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
> +	u16 pf_qos;
> +	__be16 vlan_proto;
> +	u16 min_tx_rate;
> +	u16 max_tx_rate;
> +	u8 spoofchk_enabled;
> +	bool rss_query_enabled;
> +	u8 trusted;
> +	int link_state;
> +};

Could you use proper indentation of field names ?

struct vf_data_storage {
	u8	vf_mac[ETH_ALEN];
	u16	pf_vlan; /* When set, guest VLAN config not allowed. */
	u16	pf_qos;
	__be16	vlan_proto;
	u16	min_tx_rate;
	u16	max_tx_rate;
	u8	spoofchk_enabled;
	bool	rss_query_enabled;
	u8	trusted;
	int	link_state;
};

struct dummy_priv {
	int			num_vfs;
	struct vf_data_storage	*vfinfo;
};

Thanks.
