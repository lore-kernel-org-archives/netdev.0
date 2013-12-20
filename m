From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] sch_tbf: add TBF_BURST/TBF_PBURST attribute
Date: Thu, 19 Dec 2013 17:31:34 -0800
Message-ID: <1387503094.19078.406.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com>
		 <52AFC64F.2070100@huawei.com>
	 <1387484113.19078.375.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B39C5F.1010101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33134 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3LTBbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:31:36 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so1862025pdj.30
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:31:35 -0800 (PST)
In-Reply-To: <52B39C5F.1010101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 09:24 +0800, Yang Yingliang wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> When we set burst to 1514 with low rate in userspace,
> the kernel get a value of burst that less than 1514,
> which doesn't work.
> 
> Because it may make some loss when transform burst
> to buffer in userspace. This makes burst lose some
> bytes, when the kernel transform the buffer back to
> burst.
> 
> This patch adds two new attributes to support sending
> burst/mtu to kernel directly to avoid the loss.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
