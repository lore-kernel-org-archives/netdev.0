From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed, 07 Jun 2017 19:23:40 -0700
Message-ID: <1496888620.736.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
         <1496883476-17445-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33816 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdFHCXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 22:23:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id u1so3382170pfg.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 19:23:42 -0700 (PDT)
In-Reply-To: <1496883476-17445-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-08 at 08:57 +0800, Haishuang Yan wrote:
> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so move
> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
> 
> CC: Alexei Starovoitov <ast@fb.com>
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
