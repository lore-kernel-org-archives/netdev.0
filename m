From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 resubmit] skbuff: optimize the pull_pages
 code in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 02:47:37 -0700
Message-ID: <1500284857.5566.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1500283502-36546-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33050 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751265AbdGQJrk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 05:47:40 -0400
Received: by mail-wm0-f67.google.com with SMTP id 65so2187531wmf.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 02:47:39 -0700 (PDT)
In-Reply-To: <1500283502-36546-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 17:25 +0800, Lin Zhang wrote:
> In the pull_pages code block, if the first frag size > eat,
> we can end the loop in advance to avoid extra copy.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>

Acked-by: Eric Dumazet <edumazet@google.com>
