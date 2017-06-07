From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] net: dsa: add CPU and DSA ports as VLAN
 members
Date: Wed, 07 Jun 2017 15:00:34 -0400 (EDT)
Message-ID: <20170607.150034.106912047540062374.davem@davemloft.net>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
        <20170606205631.22880-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdFGTAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:00:36 -0400
In-Reply-To: <20170606205631.22880-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue,  6 Jun 2017 16:56:29 -0400

> @@ -166,6 +166,9 @@ static int dsa_switch_vlan_add(struct dsa_switch *ds,
>  	bitmap_zero(members, ds->num_ports);
>  	if (ds->index == info->sw_index)
>  		set_bit(info->port, members);
> +	for (port = 0; port < ds->num_ports; ++port)
> +		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
> +			set_bit(port, members);

Please use the more canonical "x++" post-increment in the for() statement.

Thank you.
