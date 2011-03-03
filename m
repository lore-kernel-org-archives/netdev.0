From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: Network link detection
Date: Thu, 03 Mar 2011 17:54:12 -0600
Message-ID: <4D702A24.70805@genband.com>
References: <20110303193006.GA29129@svh.nico22.de>	<4D700A5B.2000807@genband.com> <20110303.140106.191399853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dev@nico22.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110303.140106.191399853.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/2011 04:01 PM, David Miller wrote:
> From: Chris Friesen <chris.friesen@genband.com>
> Date: Thu, 03 Mar 2011 15:38:35 -0600
> 
>> You might look at whether you could write a kernel module to register
>> for NETDEV_CHANGE notifications and pass that back to userspace.
> 
> This is the kind of responses you get when you ask networking specific
> questions and don't CC: netdev :-/

My apologies for misleading the original poster.  I can only claim a
brain fart since I've actually used rtnetlink for other things.

> There is this thing called netlink, you can listen for arbitrary
> network state change events on a socket, and get the link state
> notifications you are looking for.  It's in use by many real
> applications like NetworkManager and co.

For future reference then, to listen for link state notifications you'd
use NETLINK_ROUTE with nl_groups set to RTMGRP_LINK, and the link state
will be signaled in the if_flags field of received messages?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
