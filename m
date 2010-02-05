From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 3/4] bond: support more Layer 4 protocols
Date: Fri, 5 Feb 2010 08:42:40 -0800
Message-ID: <20100205084240.0bd895ab@s6510>
References: <20100204171118.917737392@vyatta.com>
	<20100204171241.393163298@vyatta.com>
	<4B6BF50D.9060603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41061 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab0BEQmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 11:42:52 -0500
In-Reply-To: <4B6BF50D.9060603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Feb 2010 11:38:05 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > +/* Map of protocols with standard ports available to include in hash */
> > +static const bool has_layer4[256] = {
> > +	[IPPROTO_TCP] = 1,
> > +	[IPPROTO_UDP] = 1,
> > +	[IPPROTO_UDPLITE] = 1,
> > +	[IPPROTO_SCTP] = 1,
> > +	[IPPROTO_DCCP] = 1,
> > +	[IPPROTO_ESP] = 1,
> > +};
> > +
> 
> How about using a bitmap or u8s to keep this more compact?

I thought about that, but couldn't find a clever way to initialize at
compile time other than hardcoding constants?
