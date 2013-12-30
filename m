From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/2] net_sched: two improvements to sch_netem
Date: Mon, 30 Dec 2013 10:55:02 -0800
Message-ID: <20131230105502.32d814b8@nehalam.linuxnetplumber.net>
References: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:59870 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094Ab3L3SzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:55:05 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so11904707pad.31
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:55:04 -0800 (PST)
In-Reply-To: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Dec 2013 17:35:13 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> This patchset makes two improvements to sch_netem.
> 
>  patch 1/2: Make bytes on wire more precise with qdisc_pkt_len().
>  patch 2/2: Add a new attribute to support 64-bit rates.
> 
> Yang Yingliang (2):
>   sch_netem: more precise length of packets
>   sch_netem: support of 64bit rates
> 
>  include/uapi/linux/pkt_sched.h |  1 +
>  net/sched/sch_netem.c          | 17 ++++++++++++++---
>  2 files changed, 15 insertions(+), 3 deletions(-)
> 

Looks good.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
