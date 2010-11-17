From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] ipv4: AF_INET link address family
Date: Wed, 17 Nov 2010 11:30:49 -0800 (PST)
Message-ID: <20101117.113049.15241659.davem@davemloft.net>
References: <20101116143248.GC26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935370Ab0KQTaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 14:30:24 -0500
In-Reply-To: <20101116143248.GC26669@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Tue, 16 Nov 2010 09:32:48 -0500

> Implements the AF_INET link address family exposing the per
> device configuration settings via netlink using the attribute
> IFLA_INET_CONF.
> 
> The format of IFLA_INET_CONF differs depending on the direction
> the attribute is sent. The attribute sent by the kernel consists
> of a u32 array, basically a 1:1 copy of in_device->cnf.data[].
> The attribute expected by the kernel must consist of a sequence
> of nested u32 attributes, each representing a change request,
> e.g.
> 	[IFLA_INET_CONF] = {
> 		[IPV4_DEVCONF_FORWARDING] = 1,
> 		[IPV4_DEVCONF_NOXFRM] = 0,
> 	}
> 
> libnl userspace API documentation and example available from:
> http://www.infradead.org/~tgr/libnl/doc-git/group__link__inet.html
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied.
