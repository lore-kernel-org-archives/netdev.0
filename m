From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Mon, 09 Jan 2017 09:42:32 -0800
Message-ID: <1483983752.5846.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170109150246.30215.63371.stgit@firesoul>
         <20170109150404.30215.44512.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36121 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162647AbdAIRm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:42:57 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so8588641pfd.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:42:34 -0800 (PST)
In-Reply-To: <20170109150404.30215.44512.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-09 at 16:04 +0100, Jesper Dangaard Brouer wrote:
> This reverts commit 9a99d4a50cb8 ("icmp: avoid allocating large struct
> on stack"), because struct icmp_bxm no really a large struct, and
> allocating and free of this small 112 bytes hurts performance.
> 
> Fixes: 9a99d4a50cb8 ("icmp: avoid allocating large struct on stack")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
