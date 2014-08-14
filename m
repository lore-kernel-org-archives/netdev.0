From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sit: Fix ipip6_tunnel_lookup device matching criteria
Date: Thu, 14 Aug 2014 16:08:36 +0400
Message-ID: <53ECA6C4.9080305@cogentembedded.com>
References: <1408008729-16982-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34325 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437AbaHNMIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:08:41 -0400
Received: by mail-lb0-f172.google.com with SMTP id z11so905190lbi.17
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 05:08:39 -0700 (PDT)
In-Reply-To: <1408008729-16982-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/14/2014 1:32 PM, Shmulik Ladkani wrote:

> As of 4fddbf5d78, when looking up a tunnel, tunnel's underlying

    Please also specify that commit's summary line in parens.

> interface (t->parms.link) is verified to match incoming traffic's
> ingress device.

> However the comparison was incorrectly based on skb->dev->iflink.

> Instead, dev->ifindex should be used, which correctly represents the
> interface from which the IP stack hands the ipip6 packets.

> This allows setting up sit tunnels bound to vlan interfaces (otherwise
> incoming ipip6 traffic on the vlan interface was dropped due to
> ipip6_tunnel_lookup match failure).

> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

WBR, Sergei
