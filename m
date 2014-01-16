From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v2 2/2] netem: add 64bit rates support
Date: Wed, 15 Jan 2014 19:17:12 -0800
Message-ID: <1389842232.31367.397.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389841754-22008-1-git-send-email-yangyingliang@huawei.com>
	 <1389841754-22008-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:56061 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaAPDRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 22:17:14 -0500
Received: by mail-pb0-f49.google.com with SMTP id up15so1516550pbc.36
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 19:17:13 -0800 (PST)
In-Reply-To: <1389841754-22008-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 11:09 +0800, Yang Yingliang wrote:
> netem support 64bit rates start from linux-3.13.
> Add 64bit rates support in tc tools.
> 
> tc qdisc show dev eth0
> qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 35Gbit
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  tc/q_netem.c | 29 ++++++++++++++++++++++++-----
>  1 file changed, 24 insertions(+), 5 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
