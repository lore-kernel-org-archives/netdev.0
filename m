From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/1] net: sock: Use double send/recv buff value to
 compare with max value
Date: Wed, 08 Feb 2017 08:00:01 -0800
Message-ID: <1486569601.7793.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486559235-13633-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35913 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751859AbdBHQAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:00:32 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so11937854pfo.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:00:03 -0800 (PST)
In-Reply-To: <1486559235-13633-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-08 at 21:07 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Because the value of SO_SNDBUF and SO_RCVBUF is doubled before
> assignment, so the real value of send and recv buffer could be more
> than the max sysctl config sysctl_wmem_max and sysctl_rmem_max.
> 
> Now use doulbe send/recv buffer value to compare with sysctl_wmem_max
> and sysctl_rmem_max, and it keeps consistence with SOCK_MIN_SNDBUF
> and SOCK_MIN_RCVBUF.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---

Looks completely bogus, based on your comprehension of this code.

If you need to, fix the doc, not this code.

Unless you give more details of course, why we should take your patch.
