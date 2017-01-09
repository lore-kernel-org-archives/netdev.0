From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct
 on stack"
Date: Mon, 9 Jan 2017 09:42:28 -0800
Message-ID: <CAM_iQpUNmaBx6L4CcrXkh6aFj-fEXdoGTBJt+33W3Xg-=7yhWA@mail.gmail.com>
References: <20170109150246.30215.63371.stgit@firesoul> <20170109150404.30215.44512.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36097 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162965AbdAIRm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:42:57 -0500
Received: by mail-qt0-f194.google.com with SMTP id l7so12982315qtd.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:42:49 -0800 (PST)
In-Reply-To: <20170109150404.30215.44512.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 7:04 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> This reverts commit 9a99d4a50cb8 ("icmp: avoid allocating large struct
> on stack"), because struct icmp_bxm no really a large struct, and
> allocating and free of this small 112 bytes hurts performance.

The original commit fixes a warning for large stack usage, icmp_send()
is deep in the call stack.

Your optimization for a slow path makes no sense to me.
