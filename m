From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [PATCH 2/2] usb driver for intellon int51x1 based PLC like devolo
	dlan duo
Date: Sat, 18 Apr 2009 12:51:43 -0400
Message-ID: <9e4733910904180951o5ca28479n6eb49bbe1e603248@mail.gmail.com>
References: <875730ecbea83bcb28e8698e47f8146e.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org
To: Peter Holik <peter@holik.at>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758062AbZDRQv6@vger.kernel.org>
In-Reply-To: <875730ecbea83bcb28e8698e47f8146e.squirrel@webmail.it-technology.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 18, 2009 at 12:43 PM, Peter Holik <peter@holik.at> wrote:
> usb driver for intellon int51x1 based PLC like devolo dlan duo
> with improvements suggested by the guys of the mailinglist:
> - name and prefix with int51x1 (Florian Fainelli)
> - use conversion functions cpu_to_le16 / le16_to_cpu (Oliver Neukum)
> - use pskb_may_pull instead of skb->len (Ilpo J=E4rvinen)
> - better code in tx_fixup (Ilpo J=E4rvinen)
> - use gotos for error handling (Ilpo J=E4rvinen)
>
> Signed-off-by: Peter Holik <peter@holik.at>
> ---
> =A0drivers/net/usb/Kconfig =A0 | =A0 =A08 ++
> =A0drivers/net/usb/Makefile =A0| =A0 =A01 +
> =A0drivers/net/usb/int51x1.c | =A0253 +++++++++++++++++++++++++++++++=
++++++++++++++
> =A03 files changed, 262 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/usb/int51x1.c
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 8ee2103..86c9e86 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -345,4 +345,12 @@ config USB_HSO
> =A0 =A0 =A0 =A0 =A0To compile this driver as a module, choose M here:=
 the
> =A0 =A0 =A0 =A0 =A0module will be called hso.
>
> +config USB_NET_INT51X1
> + =A0 =A0 =A0 tristate "Intellon PLC based usb adapter"
> + =A0 =A0 =A0 depends on USB_USBNET
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 Choose this option if you're using a USB-based PLC
> + =A0 =A0 =A0 =A0 (Powerline Communications) solution with an Intello=
n
> + =A0 =A0 =A0 =A0 int51x1 chip, like the "devolo dLan duo".

A few more details...

+         Choose this option if you're using a 14Mb USB-based PLC
+         (Powerline Communications) solution with an Intellon
+         INT51x1/INT5200 chip, like the "devolo dLan duo".

Is Homeplug a valid name too for this device? There are so many
Home... "standards" I get them confused.

--=20
Jon Smirl
jonsmirl@gmail.com
