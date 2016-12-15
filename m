From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH net-next] virtio_net: Support UDP Tunnel offloads.
Date: Thu, 15 Dec 2016 09:07:54 +0200
Message-ID: <CAJ3xEMh79catGjC4p7EsCqix_fmUgbcDtaz-1OUnR2xFpNq99g@mail.gmail.com>
References: <1479423717-2339-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        james.zhangming@huawei.com,
        "Michael S. Tsirkin <mst@redhat.com> (mst@redhat.com)"
        <mst@redhat.com>, Vladislav Yasevich <vyasevic@redhat.com>,
        ailan@redhat.com
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34436 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754684AbcLOHJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 02:09:18 -0500
Received: by mail-vk0-f65.google.com with SMTP id p9so7056395vkd.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 23:07:55 -0800 (PST)
In-Reply-To: <1479423717-2339-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 1:01 AM, Jarno Rajahalme <jarno@ovn.org> wrote:
> This patch is a proof-of-concept I did a few months ago for UDP tunnel
> offload support in virtio_net interface [..]

What's the use case you were considering for a guest running a UDP based VTEP?

> Real implementation needs to extend the virtio_net header rather than
> piggy-backing on existing fields.  Inner MAC length (or inner network
> offset) also needs to be passed as a new field.  Control plane (QEMU)
> also needs to be updated.
>
> All testing was done using Geneve, but this should work for all UDP
> tunnels the same.
