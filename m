From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH] rfkill-gpio: Add support for the Realtek 8723 BT
Date: Wed, 15 Jul 2015 08:27:51 +0200
Message-ID: <1436941671.20249.60.camel@hadess.net>
References: <1436825494.20249.47.camel@hadess.net>
	 <A2E649D0-855C-4DBC-8A23-7D2CF2747530@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A2E649D0-855C-4DBC-8A23-7D2CF2747530@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-14 at 17:29 +0200, Marcel Holtmann wrote:
> Hi Bastien,
> 
> > http://thread.gmane.org/gmane.linux.kernel.wireless.general/127706/
> > focu
> > s=127896
> > 
> > Signed-off-by: Bastien Nocera <hadess@hadess.net>
> > 
> > ---
> > net/rfkill/rfkill-gpio.c | 1 +
> > 1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> > index d5d58d9..9471024 100644
> > --- a/net/rfkill/rfkill-gpio.c
> > +++ b/net/rfkill/rfkill-gpio.c
> > @@ -168,6 +168,7 @@ static const struct acpi_device_id
> > rfkill_acpi_match[] = {
> > 	{ "BCM2E3D", RFKILL_TYPE_BLUETOOTH },
> > 	{ "BCM2E40", RFKILL_TYPE_BLUETOOTH },
> > 	{ "BCM2E64", RFKILL_TYPE_BLUETOOTH },
> > +	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
> > 	{ "BCM4752", RFKILL_TYPE_GPS },
> > 	{ "LNV4752", RFKILL_TYPE_GPS },
> > 	{ },
> 
> while this is most likely a good start to get people going and 
> testing the hardware, I think long-term some these IDs have to move 
> out of this driver and into a Realtek specific UART slave driver 
> (once we get such a thing upstream).
> 
> I think one example would be what Fred is currently doing for the 
> Broadcom UART devices. Essentially we are currently misusing the 
> RFKILL switch for an on/off switch of the GPIO lines. This would be 
> better handled by the Bluetooth subsystem itself when you power on 
> the controller.

Duly noted. I'll postpone that until I have time to do hardware
enablement on the Bluetooth side of that chipset.
