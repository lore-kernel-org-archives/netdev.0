From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 2/3] ipv4: share tcp_v4_save_options() with
 cookie_v4_check()
Date: Wed, 15 Oct 2014 21:16:23 -0700
Message-ID: <1413432983.28798.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1413408802-21052-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:60780 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaJPEQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 00:16:25 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so2458384pdi.24
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 21:16:25 -0700 (PDT)
In-Reply-To: <1413408802-21052-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-15 at 14:33 -0700, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> cookie_v4_check() allocates ip_options_rcu in the same way
> with tcp_v4_save_options(), we can just make it a helper function.
> 
> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
