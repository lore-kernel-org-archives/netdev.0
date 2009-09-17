From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH V2 0/3] at91_can: add support for Atmel's CAN controller
	on AT91SAM9263
Date: Thu, 17 Sep 2009 12:04:59 +0200
Message-ID: <4AB209CB.10707@pengutronix.de>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>
	<4AB20679.2040602@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Victor <linux-PelNFVqkFnVyf+4FbqDuWQ@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4AB20679.2040602-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Wolfgang Grandegger wrote:
>> This patch series adds support for the Atmel CAN controller as found
>> on the AT91SAM9263.
>>
>> It adds the at91_can to the generic device definition, activates the CAN
>> controller on the at91sam9263ek and adds the driver itself.
>>
>> Changes since V1:
>> - let Kconfig depend on CAN_DEV
>> - add example how driver is used in baord file
>>
>> Please review and consider for inclusion.
> 
> A Vx patch suffix would be nice next time.

Sorry, missed that. I was in a hurry, because they wanted to reboot the
server....

>> cheers, Marc
>>
>> Marc Kleine-Budde (3):
>>       at91sam9263: add at91_can device to generic device definition
>>       at91sam9263ek: activate at91 CAN controller
>>       at91_can: add driver for Atmel's CAN controller on AT91SAM9263
> 
> I have just added my "signed-off-by" for the Socket-CAN patch #3. Don't
> known who will take care of the other patches.

Thanks Wolfgang.

Andrew, are the first two going throught the arm tree?

cheers, Marc

- --
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkqyCMwACgkQjTAFq1RaXHP/bACfbWSs52bkNoPICUMTufN8lA4v
yqIAoI0VIrCZKEHja/XEOLHum51zpJ4V
=dn2a
-----END PGP SIGNATURE-----
