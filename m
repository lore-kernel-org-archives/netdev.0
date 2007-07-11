From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 14:23:53 +0200
Message-ID: <4694CBD9.90503@trash.net>
References: <4694A363.2070406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51714 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761622AbXGKMYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 08:24:38 -0400
In-Reply-To: <4694A363.2070406@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> +static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
> +	[VETH_INFO_MAC]		= { .type = NLA_BINARY, .len = ETH_ALEN },
> +	[VETH_INFO_PEER]	= { .type = NLA_STRING },
> +	[VETH_INFO_PEER_MAC]	= { .type = NLA_BINARY, .len = ETH_ALEN },
> +};


Looks good, just one question. What happended to the IFLA_PARTNER
attribute idea? I have a patch to allow specifying the initial
MAC address for a device, IFLA_PARTNER would make the whole thing
symetrical.
