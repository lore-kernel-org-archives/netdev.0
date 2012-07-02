From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: remove unnecessary codes in
 tcp_ipv6.c
Date: Mon, 02 Jul 2012 11:07:47 +0200
Message-ID: <1341220067.5269.37.camel@edumazet-glaptop>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49715 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310Ab2GBJHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 05:07:50 -0400
Received: by eeit10 with SMTP id t10so1972077eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 02:07:49 -0700 (PDT)
In-Reply-To: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 11:18 +0800, roy.qing.li@gmail.com wrote:
> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> opt always equals np->opts, so it is meaningless to define opt, and
> check if opt does not equal np->opts and then try to free opt.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/ipv6/tcp_ipv6.c |   16 +++-------------
>  1 files changed, 3 insertions(+), 13 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
