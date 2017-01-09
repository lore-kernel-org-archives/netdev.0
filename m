From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 0/3] net: optimize ICMP-reply code path
Date: Mon, 9 Jan 2017 09:43:52 -0800
Message-ID: <CAM_iQpWVokaBs=mvG+PKArVx_t3xVg5n9SWjj69Uu=m-ywyH+w@mail.gmail.com>
References: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34698 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936615AbdAIRoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:44:13 -0500
Received: by mail-qk0-f193.google.com with SMTP id e1so17093112qkh.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:44:13 -0800 (PST)
In-Reply-To: <20170109150246.30215.63371.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 7:03 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> Use-case: The specific case I experienced this being a bottleneck is,
> sending UDP packets to a port with no listener, which obviously result
> in kernel replying with ICMP Destination Unreachable (type:3), Port
> Unreachable (code:3), which cause the bottleneck.

Why this is a case we should care about for performance?
