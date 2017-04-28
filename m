From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v2] net: dev: Fix possible memleaks when fail to
 register_netdevice
Date: Fri, 28 Apr 2017 09:22:41 -0600
Message-ID: <7d305254-03c5-0e6a-fac9-e9f4c758bf77@gmail.com>
References: <1493349568-58635-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Gao Feng <fgao@ikuai8.com>
To: gfree.wind@foxmail.com, jiri@resnulli.us, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33844 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163041AbdD1PWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 11:22:45 -0400
Received: by mail-pg0-f68.google.com with SMTP id t7so5880028pgt.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 08:22:45 -0700 (PDT)
In-Reply-To: <1493349568-58635-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 9:19 PM, gfree.wind@foxmail.com wrote:
>  drivers/net/dummy.c     | 14 +++++++++++---
>  drivers/net/ifb.c       | 33 +++++++++++++++++++++++----------
>  drivers/net/loopback.c  | 15 ++++++++++++++-
>  drivers/net/team/team.c | 15 ++++++++++++---
>  drivers/net/veth.c      | 15 ++++++++++++++-
>  net/8021q/vlan_dev.c    | 17 +++++++++++++----
>  net/ipv4/ip_tunnel.c    | 11 ++++++++++-
>  net/ipv6/ip6_gre.c      | 18 ++++++++++++++----
>  net/ipv6/ip6_tunnel.c   | 11 ++++++++++-
>  net/ipv6/ip6_vti.c      | 11 ++++++++++-
>  net/ipv6/sit.c          | 17 +++++++++++++----
>  11 files changed, 144 insertions(+), 33 deletions(-)

Seems like the changes to each file are completely independent, so they
should be in separate patches making each easier to review.
