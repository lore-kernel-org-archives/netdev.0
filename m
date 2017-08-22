From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] tcp: Get a proper dst before checking
 it.
Date: Tue, 22 Aug 2017 11:14:56 -0700
Message-ID: <1503425696.2499.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
         <1503383629-12392-2-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34724 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbdHVSO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:14:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id w127so2396123pfd.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 11:14:58 -0700 (PDT)
In-Reply-To: <1503383629-12392-2-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 23:33 -0700, Tonghao Zhang wrote:
> tcp_peer_is_proven needs a proper route to make the
> determination, but dst always is NULL. This bug may
> be there at the beginning of git tree. This does not
> look serious enough to deserve backports to stable
> versions.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>
