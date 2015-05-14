From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock contention
Date: Thu, 14 May 2015 14:59:29 -0400
Message-ID: <CA+FuTSfU1ZTxUwTGTsbed8zMNdtNHw7uAkr3AA_PY9sbEPSNCA@mail.gmail.com>
References: <1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514.125922.1722914809373007896.davem@davemloft.net> <CA+FuTSesrSiC84pDVR=0r9uhsM5UHuQpJ=hYLvBjafOtTGUfLQ@mail.gmail.com>
 <20150514.144632.514885310313332490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33026 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932807AbbENTAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 15:00:00 -0400
Received: by obblk2 with SMTP id lk2so60154396obb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 11:59:59 -0700 (PDT)
In-Reply-To: <20150514.144632.514885310313332490.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 2:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Thu, 14 May 2015 14:35:57 -0400
>
>> This looks great, thanks. I can submit it, but it is essentially your fix.
>
> Just give me your Acked-by: and I'll apply my patch then.

Actually, I just observed a soft lockup in testing. I guess we would
need spin_lock_irqsave. I'll verify and send it.
