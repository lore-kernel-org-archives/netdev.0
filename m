From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] doc: fix the compile fix of txtimestamp.c
Date: Sun, 11 Jan 2015 21:43:10 -0800
Message-ID: <CAM_iQpUwa6m6UEXy02refyLp42Rekxtn=RGG_fdUW7LWCVZEfA@mail.gmail.com>
References: <1420909698-25025-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, vlee@twopensource.com,
	"Carlos O'Donell" <carlos@redhat.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:51827 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbbALFnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 00:43:11 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so30128865pab.4
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 21:43:10 -0800 (PST)
In-Reply-To: <1420909698-25025-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 10, 2015 at 9:08 AM, Willem de Bruijn <willemb@google.com> wrote:
>
> Due to the many libc headers included in txtimestamp.c, I was unable
> to make it compile cleanly by including the kernel header
> (linux/ipv6.h) first, as opposed to using the libc definition.
>
> Btw, should we add the libc-compat.h directly to that file, as opposed
> to reading it indirectly through linux/in6.h?
>

That seems fine.

Thanks for the fix!
