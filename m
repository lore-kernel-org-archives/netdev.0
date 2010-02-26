From: David Miller <davem@davemloft.net>
Subject: Re: Bridge: request for the via_phys_dev feature discussion
Date: Fri, 26 Feb 2010 04:30:28 -0800 (PST)
Message-ID: <20100226.043028.245172342.davem@davemloft.net>
References: <4B7D30B8.2050400@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935853Ab0BZMaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:30:10 -0500
In-Reply-To: <4B7D30B8.2050400@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Feb 2010 15:21:12 +0300

> In simple situation containers users want to bridge their containers through
> veth device with the host eth0 adapter. But after one add his eth0 to bridge
> he need to
> a) reconfigure everything including IP addresses, routing tables and
>    netfilter rules
> b) recreate connections that were bound to eth0
> 
> That's OK if one setup the box from the scratch and adds eth0 to bridge from
> the very beginning, but for those who start using containers on pre-configured
> boxes or for those, who decided to switch to bridge+veth from some other 
> virtual device (e.g. macvlan or venet device in OpenVZ) this becomes real pain.
> 
> I don't insist you accept the patches Cyrill proposed, I don't even insist
> we rework them keeping the idea intact. I just want to know your opinion about
> how to solve the above problem better.

Stephen, please work with Pavel on finding a solution for this issue
that works for you.

Thanks.
