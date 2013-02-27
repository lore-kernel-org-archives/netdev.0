From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle
Date: Wed, 27 Feb 2013 10:07:11 +0100
Message-ID: <87zjyq86rk.fsf@nemi.mork.no>
References: <1361852232.23197.4.camel@andromache.adelaide.aarnet.edu.au>
	<20130226.172856.235525833921140241.davem@davemloft.net>
	<20130226.172955.926853809838377302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gdt@gdt.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130226.172955.926853809838377302.davem@davemloft.net> (David
	Miller's message of "Tue, 26 Feb 2013 17:29:55 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> Applied, thanks Glen.
>
> Actually, I had to revert, this doesn't even compile against
> current sources:
>
>   CC [M]  drivers/net/usb/asix_devices.o
> drivers/net/usb/asix_devices.c:941:14: error: =E2=80=98asix_rx_fixup=E2=
=80=99 undeclared here (not in a function)
> make[1]: *** [drivers/net/usb/asix_devices.o] Error 1
> make: *** [drivers/net/usb/asix_devices.o] Error 2

I believe this patch will make checkpatch cry

  ERROR: do not use C99 // comments

as well.  It would be nice if that was fixed as well before resending.
But please keep the commit message :)


Bj=C3=B8rn
