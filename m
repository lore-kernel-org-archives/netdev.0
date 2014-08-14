From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] sit: Fix ipip6_tunnel_lookup device matching criteria
Date: Thu, 14 Aug 2014 12:17:05 +0200
Message-ID: <53EC8CA1.6060909@6wind.com>
References: <1408008729-16982-1-git-send-email-shmulik.ladkani@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44204 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbaHNKRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 06:17:12 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so2037743wib.5
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 03:17:07 -0700 (PDT)
In-Reply-To: <1408008729-16982-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/08/2014 11:32, Shmulik Ladkani a =C3=A9crit :
> As of 4fddbf5d78, when looking up a tunnel, tunnel's underlying
Please, put also the subject of the commit like this:
4fddbf5d7854 ("sit: strictly restrict incoming traffic to tunnel link d=
evice")

> interface (t->parms.link) is verified to match incoming traffic's
> ingress device.
>
> However the comparison was incorrectly based on skb->dev->iflink.
>
> Instead, dev->ifindex should be used, which correctly represents the
> interface from which the IP stack hands the ipip6 packets.
>
> This allows setting up sit tunnels bound to vlan interfaces (otherwis=
e
> incoming ipip6 traffic on the vlan interface was dropped due to
> ipip6_tunnel_lookup match failure).
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
