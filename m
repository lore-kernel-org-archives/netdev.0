From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 1/2] net: add and use skb_gso_transport_seglen()
Date: Sun, 26 Jan 2014 08:51:59 -0800
Message-ID: <1390755119.27806.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390730297-10725-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:50504 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbaAZQwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 11:52:00 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so5029505pab.31
        for <netdev@vger.kernel.org>; Sun, 26 Jan 2014 08:52:00 -0800 (PST)
In-Reply-To: <1390730297-10725-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-26 at 10:58 +0100, Florian Westphal wrote:
> This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
> skbuff core so it may be reused by upcoming ip forwarding path patch.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since V1:
>  suggestions from Eric Dumazet:
>   - don't use uapi udp.h
>   - remove tcp.h include from tbf, its not needed anymore
> 
>  include/linux/skbuff.h |  1 +
>  net/core/skbuff.c      | 25 +++++++++++++++++++++++++
>  net/sched/sch_tbf.c    | 13 +++----------
>  3 files changed, 29 insertions(+), 10 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
