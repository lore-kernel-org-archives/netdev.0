From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv6: move stub initialization after ipv6 setup completion
Date: Mon, 24 Apr 2017 10:02:08 -0700
Message-ID: <CAM_iQpW9v+XrMEe_sp02pWtud7KvTPBiJKSZNcrSV3aJx2H8SQ@mail.gmail.com>
References: <fd7c85f650661466a782a71485f227f0b84454a7.1493035843.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37976 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975341AbdDXRCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:02:40 -0400
Received: by mail-wm0-f51.google.com with SMTP id r190so74038225wme.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 10:02:39 -0700 (PDT)
In-Reply-To: <fd7c85f650661466a782a71485f227f0b84454a7.1493035843.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 5:18 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> The ipv6 stub pointer is currently initialized before the ipv6
> routing subsystem: a 3rd party can access and use such stub
> before the routing data is ready.
> Moreover, such pointer is not cleared in case of initialization
> error, possibly leading to dangling pointers usage.
>
> This change addresses the above moving the stub initialization
> at the end of ipv6 init code.
>
> Fixes: 5f81bd2e5d80 ("ipv6: export a stub for IPv6 symbols used by vxlan")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
