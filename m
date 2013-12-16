From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Mon, 16 Dec 2013 05:47:10 -0800
Message-ID: <1387201630.19078.228.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:63682 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309Ab3LPNrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:47:12 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so5477113pbb.31
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 05:47:11 -0800 (PST)
In-Reply-To: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 16:31 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The commit ecd9883724b [ipv6: fix race condition regarding dst->expires and
> dst->from.] removed rt6_clean_expires in ip6_rt_copy, which causes the TAHI
> test case v6LC.4.1.4 { Reduce PMTU On-link } failed, since the newly generated
> rt maybe always expired {with RTF_EXPIRES flag, dst.expires is 0, and dst.from
> is NULL}.
> 
> Fix it by clearing RTF_EXPIRES as before 1716a96101[ipv6: fix problem with
> expired dst cache]

Any particular reason you didnt CC the author of the commit ?

Thanks
