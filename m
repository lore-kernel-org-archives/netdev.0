From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] ipv6: Prevent unexpected sk->sk_prot
 changes
Date: Tue, 15 Aug 2017 04:39:38 -0700
Message-ID: <1502797178.4936.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502795320-22538-1-git-send-email-ilyal@mellanox.com>
         <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davejwatson@fb.com,
        aviadye@mellanox.com, Boris Pismenny <borisp@mellanox.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:37140 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdHOLjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 07:39:41 -0400
Received: by mail-pg0-f41.google.com with SMTP id y129so4286948pgy.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 04:39:40 -0700 (PDT)
In-Reply-To: <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 14:08 +0300, Ilya Lesokhin wrote:
> With this patch IPV6 code ensure that only sockets with the
> expected sk->sk_prot are converted to IPV4.

It looks like you fix a bug added by a recent commit (in net-next, not
in net tree) ?

Please provide Fixes: tag to ease code review and maintenance.

Thanks.
