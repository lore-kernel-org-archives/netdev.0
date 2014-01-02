From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Wed, 01 Jan 2014 19:56:23 -0800
Message-ID: <1388634983.12212.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:54463 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbaABD4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:56:25 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so13857173pbc.6
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 19:56:24 -0800 (PST)
In-Reply-To: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 08:49 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when read/write the 64bit data, the correct lock should be hold. and use the
> BUILD_BUG_ON check to ensure the syncp is last element of struct pcpu_tstats,
> then reduce the copy the syncp when get the stats

No idea of why you added a BUILD_BUG_ON(), this makes no sense.

> 
> Eric Dumazet <edumazet@google.com>

Why is my name mentioned in this changelog ?

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/ip6_tunnel.c |   25 ++++++++++++++++++-------
>  1 file changed, 18 insertions(+), 7 deletions(-)

Could you find out when the bug was introduced ?

Ideally you should add :

Fixes : 12-digit SHA1 ("patch title")

Thanks
