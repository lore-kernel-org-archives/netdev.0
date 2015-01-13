From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] ipv6: directly include libc-compat.h in ipv6.h
Date: Tue, 13 Jan 2015 10:50:25 -0800
Message-ID: <CAM_iQpX2QO5ttWK3yb6Dyw=DJSf4o4Fz9koPDi6iq0SHTHvD2g@mail.gmail.com>
References: <1421090974-30018-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50876 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbAMSuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:50:25 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so5202026pac.11
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:50:25 -0800 (PST)
In-Reply-To: <1421090974-30018-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 11:29 AM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Patch 3b50d9029809 ("ipv6: fix redefinition of in6_pktinfo ...")
> fixed a libc compatibility issue in ipv6 structure definitions
> as described in include/uapi/linux/libc-compat.h.
>
> It relies on including linux/in6.h to include libc-compat.h itself.
> Include that file directly to clearly communicate the dependency
> (libc-compat.h: "This include must be as early as possible").
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for the patch!
