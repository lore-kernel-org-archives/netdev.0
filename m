From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 23:01:49 +0100
Message-ID: <40e87e75-742f-3542-b79e-1e7fee9b4485@cambridgegreys.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
 <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
 <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
 <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
 <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36660 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdJKWB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 18:01:56 -0400
In-Reply-To: <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> This will be tomorrow though, it is late here.
>
> The only obvious difference I can see at this point is that I am using
> iovs and sending the vnet header as iov[0] and the data in pieces after
> that while your code is doing a send() for the whole frame. This should
> not make any difference though - it all ends up as an iov internally in
> the kernel.

Spoke too soon. It is not reporting any errors, but there is nothing
coming out on the actual Ethernet.

Leaving it till tomorrow.

A.

>
> A.
>
>


-- 
Anton R. Ivanov
Cambridgegreys Limited. Registered in England. Company Number 10273661
