From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 18:59:34 -0700
Message-ID: <1431655174.27831.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431653605-11922-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com,
	davem@davemloft.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37915 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945924AbbEOB7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 21:59:37 -0400
Received: by igbhj9 with SMTP id hj9so93393176igb.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 18:59:36 -0700 (PDT)
In-Reply-To: <1431653605-11922-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 09:33 +0800, Ying Xue wrote:
> Once we get a neighbour through looking up arp cache or creating a
> new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
> already taken. But as we don't put the refcount again after it's
> used, this makes the neighbour entry leaked.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
> v2:

Acked-by: Eric Dumazet <edumazet@google.com>
