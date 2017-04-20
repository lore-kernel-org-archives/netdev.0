From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from userspace
Date: Thu, 20 Apr 2017 15:39:28 -0700
Message-ID: <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Martin KaFai Lau <kafai@fb.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34896 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947777AbdDTWju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:39:50 -0400
Received: by mail-wm0-f67.google.com with SMTP id d79so1334212wmi.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:39:49 -0700 (PDT)
In-Reply-To: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 2:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
> Fix by checking for the flag and failing with EINVAL.
>

I am still not sure about this. There are a few unused bits in
this flag, we simply ignore the rest, right? Why should we
reject this one instead of all of those we don't use?
