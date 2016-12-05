From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 net 10/20] net/ena: remove redundant logic in napi
 callback for busy poll mode
Date: Mon, 05 Dec 2016 10:51:09 -0800
Message-ID: <1480963869.18162.557.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
         <1480857578-5065-11-git-send-email-netanel@annapurnalabs.com>
         <1480916739.18162.516.camel@edumazet-glaptop3.roam.corp.google.com>
         <8c6eb7b9-c9fc-60f6-c890-5d69c0cc1cd9@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35966 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbcLESwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:52:12 -0500
In-Reply-To: <8c6eb7b9-c9fc-60f6-c890-5d69c0cc1cd9@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-05 at 20:29 +0200, Netanel Belgazal wrote:

> You are correct.
> I didn't see the patches.
> It is much better to use the napi_complete_done() return value.
> I'll rework my patch.

Excellent, please CC me on this particular work on the future.

Thanks.
