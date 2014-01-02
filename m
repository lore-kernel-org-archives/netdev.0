From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 13:49:25 -0800
Message-ID: <CA+55aFwF6f84Rd0C8WmLia4EcJc1CZH8GvEZXWfE2=VH0_mxSw@mail.gmail.com>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	<20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
	<370106E9-5C39-4917-AE74-2ED5E376DA11@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:38816 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbaABVt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 16:49:26 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so6471746ead.24
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 13:49:25 -0800 (PST)
In-Reply-To: <370106E9-5C39-4917-AE74-2ED5E376DA11@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 1:41 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
>
> if you are using the stir4200 driver then you are using an USB dongle that does not need the irattach to make it known to the IrDA subsystem. It will automatically make it known. For every IrDA dongle you attach you should see an irdaX with ifconfig.

I don't actually want to use the USB dongle if I can avoid it. I've
*tried* it, but it has the exact same issue as the pty has, namely
that it doesn't really work reliably.

So for debugging I'd actually much prefer to use the pty approach.

I don't have any devices that use irda (the dive computers that showed
the problem are expensive and not any that I personally would actually
want to buy), so I'm trying to recreate the problems using a loopback
system.

(I have a non-ircomm version too, which has a device emulation on one
end of the pty, and uses a irda socket on another end. That one is
very specialized for the dive computer thing, though, which is why I
wanted to first try to do something "simpler" using just ircomm at
both ends).

               Linus
