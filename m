From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 14:13:50 -0800
Message-ID: <0A3D681C-9597-44F0-9540-B42F259004D1@holtmann.org>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com> <20140102.034653.1968429090467668489.davem@davemloft.net> <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com> <370106E9-5C39-4917-AE74-2ED5E376DA11@holtmann.org> <CA+55aFwF6f84Rd0C8WmLia4EcJc1CZH8GvEZXWfE2=VH0_mxSw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43726 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaABWN6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:13:58 -0500
In-Reply-To: <CA+55aFwF6f84Rd0C8WmLia4EcJc1CZH8GvEZXWfE2=VH0_mxSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

>> if you are using the stir4200 driver then you are using an USB dongle that does not need the irattach to make it known to the IrDA subsystem. It will automatically make it known. For every IrDA dongle you attach you should see an irdaX with ifconfig.
> 
> I don't actually want to use the USB dongle if I can avoid it. I've
> *tried* it, but it has the exact same issue as the pty has, namely
> that it doesn't really work reliably.
> 
> So for debugging I'd actually much prefer to use the pty approach.
> 
> I don't have any devices that use irda (the dive computers that showed
> the problem are expensive and not any that I personally would actually
> want to buy), so I'm trying to recreate the problems using a loopback
> system.
> 
> (I have a non-ircomm version too, which has a device emulation on one
> end of the pty, and uses a irda socket on another end. That one is
> very specialized for the dive computer thing, though, which is why I
> wanted to first try to do something "simpler" using just ircomm at
> both ends).

I do not think that the irattach emulation idea of PTY is going to work for you. irattach is pretty much specialized to the underlaying IrDA hardware that is attached to its exposed (or physically connected) TTY.

As far as I recall, there was never any loopback emulation implemented in Linux that you could use. So you need to go through real IrDA hardware if you want to do anything useful. You might be just out of luck with the IrDA subsystem and its capabilities to do any easy development.

Maybe irdadump is helping you do debug some parts, but that tool might be as outdated as everything else.

Back in the days, I had more success with the stir4200 based USB dongles than any of the TTY based ones. But my bet is also that this all goes back 10 years, so my brain could clearly play tricks on me.

Regards

Marcel
