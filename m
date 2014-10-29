From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 18:17:35 -0700
Message-ID: <CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:60222 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbaJ2BRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 21:17:38 -0400
Received: by mail-qg0-f50.google.com with SMTP id a108so1503928qge.23
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 18:17:37 -0700 (PDT)
In-Reply-To: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 6:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> napi_schedule() can be called from any context and has to mask hard
> irqs.
>
> Add a variant that can only be called from hard interrupts handlers
> or when irqs are already masked.
>
> Many NIC drivers can use it from their hard IRQ handler instead of
> generic variant.

Interesting! Are you trying to optimize some of such NIC drivers? ;)
but all of 10G+ and virtio won't apply, right?
