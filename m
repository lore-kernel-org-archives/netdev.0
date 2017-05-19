From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] e1000e: use disable_hardirq() also for MSIX vectors in e1000_netpoll()
Date: Fri, 19 May 2017 11:34:43 -0700
Message-ID: <CAM_iQpUD9qJepFn-8M32+VcureTgM77-beY9=+tm0jC7Btkg7Q@mail.gmail.com>
References: <149517832870.37403.16008624383220981105.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        "David S. Miller" <davem@davemloft.net>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Thomas Gleixner <tglx@linutronix.de>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33931 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755878AbdESSfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 14:35:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id d127so19770541wmf.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 11:35:04 -0700 (PDT)
In-Reply-To: <149517832870.37403.16008624383220981105.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 12:18 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> Replace disable_irq() which waits for threaded irq handlers with
> disable_hardirq() which waits only for hardirq part.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 311191297125 ("e1000: use disable_hardirq() for e1000_netpoll()")

Thomas had a similar patch, I don't know why he never sends it
out formally. Anyway,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
