From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 1/2] usbnet: Style cleanups
Date: Tue, 3 May 2011 20:49:41 +0200
Message-ID: <201105032049.41433.oneukum@suse.de>
References: <cover.1304445019.git.joe@perches.com> <3592918df9ee156047042aae16531e96db0b7144.1304445019.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	"Greg Kroah-Hartman" <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3592918df9ee156047042aae16531e96db0b7144.1304445019.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 3. Mai 2011, 20:17:57 schrieb Joe Perches:
>  drivers/net/usb/usbnet.c |  625 +++++++++++++++++++++++-------------=
---------
>  1 files changed, 319 insertions(+), 306 deletions(-)
>=20
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 7bc9852..28aecbb 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -30,8 +30,8 @@
>   * issues can usefully be addressed by this framework.
>   */
> =20
> -// #define     DEBUG                   // error path messages, extra=
 info
> -// #define     VERBOSE                 // more; success messages
> +/* #define     DEBUG                   // error path messages, extra=
 info */
> +/* #define     VERBOSE                 // more; success messages */

Hi,

1. please don't touch things like that. They are not comments in a sema=
ntic sense
2. If you are touching comments, please redo the multiline comments acc=
ording to
the coding style.
3. please delay these modifications until the patches against the oom p=
roblem have
been applied

	Regards
		Oliver

--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
