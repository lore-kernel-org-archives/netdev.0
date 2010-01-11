From: christian pellegrin <chripell@gmail.com>
Subject: Re: problem with kernel ipconfig over usb ethernet on v.2.6.33-rc3
Date: Mon, 11 Jan 2010 08:18:13 +0100
Message-ID: <cabda6421001102318m972e0bdw3f44962b5307d4b@mail.gmail.com>
References: <cabda6421001100027u1ca339a6ka46470431caa21ba@mail.gmail.com>
	 <20100110.133848.200626367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:56246 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab0AKHSP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 02:18:15 -0500
Received: by fxm7 with SMTP id 7so19441035fxm.29
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 23:18:13 -0800 (PST)
In-Reply-To: <20100110.133848.200626367.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 10:38 PM, David Miller <davem@davemloft.net> wr=
ote:
>
> How long does it actually take for the USB ethernet device
> to become visible at this point?
>
> Is 2 seconds enough? =A0For example.

no, it's around 8-9 seconds

>
> It's rediculious to require that users learn about obscure
> kernel command line options in order for basic functionality
> to work properly.
>

I agree with you, unfortunately rootdelay is there and it's rather
difficult to boot from USB mass storage or even SCSI arrays without
it. If you think it's worth the hassle (maybe this is not a common
user case: I have to develop on embedded systems where the hardware
designers try to save every possible euro by not including proper
ethernet MACs; on desktop systems having initrd/initramfs setting up
the device and waiting for them via udevd solved the problem (but they
don't use kernel ipconfig either in this case)) I can try more
elaborate schemes like: if the ethX specified by ip=3D is not present a=
t
the first try just wait 10 seconds and try again (perhaps repeat this
two time just to be sure).

--=20
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
