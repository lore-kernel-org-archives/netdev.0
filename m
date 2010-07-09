From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 23:10:58 -0700 (PDT)
Message-ID: <20100708.231058.245410427.davem@davemloft.net>
References: <1278604985.2651.35.camel@edumazet-laptop>
	<1278607037.2651.57.camel@edumazet-laptop>
	<1278613548.16013.193.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171Ab0GIGKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:10:44 -0400
In-Reply-To: <1278613548.16013.193.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 08 Jul 2010 19:25:48 +0100

> On Thu, 2010-07-08 at 18:37 +0200, Eric Dumazet wrote:
>> When we need to shape traffic using low speeds, we need to
>> disable tso on network interface :
>> 
>> ethtool -K eth0.2240 tso off
>> 
>> It seems vlan interfaces miss the set_tso() ethtool method.
>> 
>> Before enabling TSO, we must check real device supports 
>> TSO for VLAN-tagged packets and enables TSO.
>> 
>> Note that a TSO change on real device propagates TSO setting
>> on all vlans, even if admin selected a different TSO setting.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Ok, just to clarify, I'll make sure I get this version instead of "v2"
which I just replied to :)
