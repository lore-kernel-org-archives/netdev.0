From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Wed, 25 Jan 2012 21:38:02 -0500 (EST)
Message-ID: <20120125.213802.119259327303074622.davem@davemloft.net>
References: <25353423.731327481250682.JavaMail.root@5-MeO-DMT.ynet.sk>
	<32686570.751327481334943.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <32686570.751327481334943.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Wed, 25 Jan 2012 09:48:54 +0100 (CET)

> +		if (vlan->mode == MACVLAN_MODE_SOURCE &&
> +			vlan->mode != nla_get_u32(data[IFLA_MACVLAN_MODE]))
 ...
> +	if (data && data[IFLA_MACVLAN_MACADDR_MODE] &&
> +		data[IFLA_MACVLAN_MACADDR]) {
 ...
> +				return macvlan_hash_add_sources(vlan,
> +					nla_data(data[IFLA_MACVLAN_MACADDR]));
 ...
> +			hlist_for_each_entry_rcu(list, n,
> +				&vlan->port->vlan_source_hash[i], hlist) {
 ...
> +			hlist_for_each_entry_rcu(list, n,
> +				&vlan->port->vlan_source_hash[i], hlist) {

Line things up on subsequent lines to the column right after the
openning parenthesis on the previous line.

If things are indented too deeply, you need to write helper functions.
