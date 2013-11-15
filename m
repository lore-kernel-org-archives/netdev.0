From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: sched: htb: fix calculation of quantum
Date: Fri, 15 Nov 2013 06:01:09 -0800
Message-ID: <1384524069.28716.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
	 <1384419714-24364-4-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:52646 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab3KOOBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 09:01:11 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj1so3649633pad.21
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 06:01:11 -0800 (PST)
In-Reply-To: <1384419714-24364-4-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:01 +0800, Yang Yingliang wrote:
> Now, 32bit rates may be not the true rate.
> So use rate_bytes_ps which is from
> max(rate32, rate64) to calcualte quantum.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_htb.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
