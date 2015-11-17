From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net] net: use skb_clone to avoid alloc_pages failure.
Date: Tue, 17 Nov 2015 05:49:08 -0800
Message-ID: <1447768148.22599.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447764570-22647-1-git-send-email-martinbj2008@gmail.com>
	 <1447765643.22599.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Junwei Zhang <linggao.zjw@alibaba-inc.com>
To: martinbj2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34802 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbbKQNtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:49:10 -0500
Received: by padhx2 with SMTP id hx2so9846462pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:49:09 -0800 (PST)
In-Reply-To: <1447765643.22599.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 05:07 -0800, Eric Dumazet wrote:
> On Tue, 2015-11-17 at 20:49 +0800, martinbj2008@gmail.com wrote:
> > From: Martin Zhang <martinbj2008@gmail.com>
> > 
> > 1. new skb only need dst and ip address(v4 or v6).
> > 2. skb_copy may need high order pages, which is very rare on long running server.
> > 
> > Signed-off-by: Junwei Zhang <linggao.zjw@alibaba-inc.com>
> > Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 

BTW, very nice catch, thanks guys !
