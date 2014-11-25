From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2] iplink: allow to show ip addresses
Date: Tue, 25 Nov 2014 07:10:23 +0100
Message-ID: <20141125061023.GA8819@unicorn.suse.cz>
References: <1416847337-23661-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59853 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841AbaKYGKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 01:10:25 -0500
Content-Disposition: inline
In-Reply-To: <1416847337-23661-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 05:42:17PM +0100, Nicolas Dichtel wrote:
> This patch adds a new option (-addresses) to the 'ip link' command so that the
> user can display link details and IP addresses with the same command.
> 
> Example:
> $ ip -d -a l ls gre1
> 9: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN mode DEFAULT group default
>     link/gre 10.16.0.249 peer 10.16.0.121 promiscuity 0
>     gre remote 10.16.0.121 local 10.16.0.249 ttl inherit ikey 0.0.0.10 okey 0.0.0.10 icsum ocsum
>     inet 192.168.0.249 peer 192.168.0.121/32 scope global gre1
>        valid_lft forever preferred_lft forever
>     inet6 fe80::5efe:a10:f9/64 scope link
>        valid_lft forever preferred_lft forever

Perhaps it would be more consistent to add -d option to "ip addr show" 
instead as we already have -s for statistics there (commit 5d5cf1b43).

                                                       Michal Kubecek
