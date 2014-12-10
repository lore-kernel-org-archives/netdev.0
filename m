From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] ipaddress: enable -details option
Date: Tue, 9 Dec 2014 20:14:38 -0800
Message-ID: <20141209201438.6f390256@urahara>
References: <20141125061023.GA8819@unicorn.suse.cz>
	<1417711267-13334-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, mkubecek@suse.cz,
	jbenc@redhat.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46679 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbaLJEOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:14:48 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so1943103pac.8
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:14:48 -0800 (PST)
In-Reply-To: <1417711267-13334-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Dec 2014 17:41:07 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This option was used only for 'ip link', but it can be useful to have it for
> 'ip address'. Thus it is possible to display link details and addresses with one
> command.
> 
> Example:
> $ ip -d a ls dev gre1
> 9: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN group default
>     link/gre 10.16.0.249 peer 10.16.0.121 promiscuity 0
>     gre remote 10.16.0.121 local 10.16.0.249 ttl inherit ikey 0.0.0.10 okey 0.0.0.10 icsum ocsum
>     inet 192.168.0.249 peer 192.168.0.121/32 scope global gre1
>        valid_lft forever preferred_lft forever
>     inet6 fe80::5efe:a10:f9/64 scope link
>        valid_lft forever preferred_lft forever
> 
> Suggested-by: Christophe Gouault <christophe.gouault@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks good, accepted.
