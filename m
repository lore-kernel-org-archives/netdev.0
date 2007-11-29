From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv7 0/5 + 3] Interface group patches
Date: Thu, 29 Nov 2007 17:25:27 +0100
Message-ID: <474EE7F7.5000108@trash.net>
References: <11963527094077-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49991 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758303AbXK2QZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:25:33 -0500
In-Reply-To: <11963527094077-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Hello,
> 
> This is the 7th version of our interface group patches.


> Patches:
>  [1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
>  [2/5] rtnetlink: send a single notification on device state changes
>  [3/5] Interface group: core (netlink) part
>  [4/5] Ifgroup read/write support in sysfs

I vote for these to go in, they're ready and there's no use in
reposting them again and again.

>  [5/5] Netfilter Interface group match

Then I'd queue this one and fix it up on top of my current tree

>  [iptables]Interface group match

This one I would queue until we have released the 1.4.0 version
of iptables. I don't want to release things that are not in
at least a -rc kernel yet.

>  [iproute2 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
>  [iproute2 2/2] Interface group as new ip link option

And for these Stephen has to decide, but both look fine to me.

