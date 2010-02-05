From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 3/4] bond: support more Layer 4 protocols
Date: Fri, 05 Feb 2010 11:38:05 +0100
Message-ID: <4B6BF50D.9060603@trash.net>
References: <20100204171118.917737392@vyatta.com> <20100204171241.393163298@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33459 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab0BEKiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 05:38:09 -0500
In-Reply-To: <20100204171241.393163298@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> +/* Map of protocols with standard ports available to include in hash */
> +static const bool has_layer4[256] = {
> +	[IPPROTO_TCP] = 1,
> +	[IPPROTO_UDP] = 1,
> +	[IPPROTO_UDPLITE] = 1,
> +	[IPPROTO_SCTP] = 1,
> +	[IPPROTO_DCCP] = 1,
> +	[IPPROTO_ESP] = 1,
> +};
> +

How about using a bitmap or u8s to keep this more compact?
