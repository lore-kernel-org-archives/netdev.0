From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 RFC net-next 4/7] tcp: replace dst_confirm with
 sk_dst_confirm
Date: Sun, 29 Jan 2017 11:27:36 -0800
Message-ID: <1485718056.6360.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485613578-19973-1-git-send-email-ja@ssi.bg>
         <1485613578-19973-5-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35262 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751149AbdA2T1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 14:27:38 -0500
In-Reply-To: <1485613578-19973-5-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-01-28 at 16:26 +0200, Julian Anastasov wrote:
> When same struct dst_entry can be used for many different
> neighbours we can not use it for pending confirmations.
> Use the new sk_dst_confirm() helper to propagate the
> indication from received packets to sock_confirm_neigh().
> 
> Reported-by: YueHaibing <yuehaibing@huawei.com>
> Fixes: 5110effee8fd ("net: Do delayed neigh confirmation.")
> Fixes: f2bb4bedf35d ("ipv4: Cache output routes in fib_info nexthops.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

For the whole series,

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
