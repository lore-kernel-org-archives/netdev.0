From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: fix a use after free
Date: Fri, 17 Oct 2014 17:59:20 +0200
Message-ID: <CAEP_g=_THguSD3BOMJYOmasirfNi6ZSLLJ_AazY+FyprW6jGFA@mail.gmail.com>
References: <1413525788-2272-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:37353 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752658AbaJQP7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 11:59:43 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so750896qga.30
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 08:59:41 -0700 (PDT)
In-Reply-To: <1413525788-2272-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 8:03 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> pskb_may_pull() called by arphdr_ok can change skb->data, so put the arp
> setting after arphdr_ok to avoid the use the freed memory
>
> Fixes: 0714812134d7d ("openvswitch: Eliminate memset() from flow_extract.")
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Jesse Gross <jesse@nicira.com>
