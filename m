From: David Miller <davem@davemloft.net>
Subject: Re: Network link detection
Date: Thu, 03 Mar 2011 14:01:06 -0800 (PST)
Message-ID: <20110303.140106.191399853.davem@davemloft.net>
References: <20110303193006.GA29129@svh.nico22.de>
	<4D700A5B.2000807@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@nico22.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: chris.friesen@genband.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D700A5B.2000807@genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Friesen <chris.friesen@genband.com>
Date: Thu, 03 Mar 2011 15:38:35 -0600

> You might look at whether you could write a kernel module to register
> for NETDEV_CHANGE notifications and pass that back to userspace.

This is the kind of responses you get when you ask networking specific
questions and don't CC: netdev :-/

There is this thing called netlink, you can listen for arbitrary
network state change events on a socket, and get the link state
notifications you are looking for.  It's in use by many real
applications like NetworkManager and co.
