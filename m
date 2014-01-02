From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 14:54:39 -0800
Message-ID: <CA+55aFz2FJt0jJzC_aSPAHafM1sSCHtn2152aER6XgioUJcxVg@mail.gmail.com>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	<20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
	<370106E9-5C39-4917-AE74-2ED5E376DA11@holtmann.org>
	<CA+55aFwF6f84Rd0C8WmLia4EcJc1CZH8GvEZXWfE2=VH0_mxSw@mail.gmail.com>
	<0A3D681C-9597-44F0-9540-B42F259004D1@holtmann.org>
	<CA+55aFywkFkrRPoG9Ze_Vc=09qG-9iYS81D13OUDhPRDsvuQeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:60304 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaABWyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:54:40 -0500
Received: by mail-ea0-f170.google.com with SMTP id k10so6467918eaj.15
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:54:39 -0800 (PST)
In-Reply-To: <CA+55aFywkFkrRPoG9Ze_Vc=09qG-9iYS81D13OUDhPRDsvuQeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 2:29 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So I do have two dongles, because I was afraid of that. Can you tell
> me how to debug *those* just connected to each other? Preferably on
> the same machine, because I'll be traveling soon..

Side note: is there any *reason* why two pty's connected to each other
can't work? They should look very much like a dongle that just doesn't
do any encapsulation of the data, and it really *almost* works. I can
actually get the simulator that uses the irda sockets to run over
them, except it will hang eventually in some timing-dependent manner.

It works well enough that I'd be inclined to blame some kernel bug.
Especially considering that I found what looked like obvious kernel
bugs already (neither of which fixes the hang, though).

             Linus
