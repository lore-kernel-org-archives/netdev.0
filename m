From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 4/4] ip_tunnel: Remove double unregister of the fallback
 device
Date: Tue, 01 Oct 2013 12:00:44 +0200
Message-ID: <524A9D4C.9030900@6wind.com>
References: <20131001093359.GG7660@secunet.com> <20131001093737.GJ7660@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44261 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab3JAKAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:00:48 -0400
Received: by mail-wi0-f172.google.com with SMTP id hn9so5234470wib.11
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 03:00:46 -0700 (PDT)
In-Reply-To: <20131001093737.GJ7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/2013 11:37, Steffen Klassert a =E9crit :
> When queueing the netdevices for removal, we queue the
> fallback device twice in ip_tunnel_destroy(). The first
> time when we queue all netdevices in the namespace and
> then again explicitly. Fix this by removing the explicit
> queueing of the fallback device.
>
> Bug was introduced when network namespace support was added
> with commit 6c742e714d8 ("ipip: add x-netns support").
>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Note that there is the same problem in=20
net/ipv6/ip6_tunnel.c:ip6_tnl_destroy_tunnels() introduced by 0bd876282=
4e7
("ip6tnl: add x-netns support").

Should I send a patch for it or would you take care of it?
