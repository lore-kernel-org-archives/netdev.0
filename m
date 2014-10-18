From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: fix a potential use after free in sit.c
Date: Sat, 18 Oct 2014 08:52:20 -0700
Message-ID: <1413647540.27176.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413624818-20804-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ghorbel@pivasoftware.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:56575 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaJRPwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 11:52:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so2547916pab.34
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 08:52:21 -0700 (PDT)
In-Reply-To: <1413624818-20804-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-18 at 17:33 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make iph pointer oboslete,
> fix it by geting ip header length directly.
> 
> Fixes: ca15a078 (sit: generate icmpv6 error when receiving icmpv4 error)
> Cc: Oussama Ghorbel <ghorbel@pivasoftware.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/sit.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for doing all these checks !
