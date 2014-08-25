From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 08/12] net: dsa: allow updating fixed PHY
 link information
Date: Sun, 24 Aug 2014 21:56:40 -0700 (PDT)
Message-ID: <20140824.215640.337563003220597230.davem@davemloft.net>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
	<1408905869-10471-9-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemlof.net, jhs@mojatatu.com,
	linville@tuxdriver.com, alexander.h.duyck@intel.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbaHYE4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 00:56:42 -0400
In-Reply-To: <1408905869-10471-9-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 24 Aug 2014 11:44:25 -0700

> @@ -389,6 +401,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  	struct dsa_switch *ds = p->parent;
>  	struct dsa_chip_data *cd = ds->pd;
>  	struct device_node *phy_dn, *port_dn;
> +	unsigned int phy_is_fixed = 0;

Please make this a bool.
