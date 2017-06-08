From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Wed, 07 Jun 2017 19:21:20 -0700
Message-ID: <1496888480.736.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pravin B Shelar <pshelar@nicira.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35191 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdFHCVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 22:21:22 -0400
In-Reply-To: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-08 at 08:57 +0800, Haishuang Yan wrote:
> When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
> 
> CC: Pravin B Shelar <pshelar@nicira.com>
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks a lot.
