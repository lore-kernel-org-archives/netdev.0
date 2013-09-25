From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] net: qmi_wwan: add Telit LE920 newer firmware support
Date: Wed, 25 Sep 2013 18:15:35 +0200
Message-ID: <87txh8op20.fsf@nemi.mork.no>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dan Williams <dcbw@redhat.com>
To: Fabio Porcedda <fabio.porcedda@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48525 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495Ab3IYQPt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 12:15:49 -0400
In-Reply-To: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
	(Fabio Porcedda's message of "Wed, 25 Sep 2013 11:21:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46abio Porcedda <fabio.porcedda@gmail.com> writes:

> Newer firmware use a new pid and a different interface.
>
> Signed-off-by: Fabio Porcedda <fabio.porcedda@gmail.com>
> ---
>  drivers/net/usb/qmi_wwan.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 6312332..5f6b6fa 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -714,6 +714,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 *=
/
>  	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
>  	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
> +	{QMI_FIXED_INTF(0x1bc7, 0x1201, 2)},	/* Telit LE920 */
>  	{QMI_FIXED_INTF(0x1e2d, 0x12d1, 4)},	/* Cinterion PLxx */
> =20
>  	/* 4. Gobi 1000 devices */

You can add my

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

to this patch if you like.  But I guess you may have to resend it if th=
e
netdev maintainer agree with me regarding the line length patch.


Bj=C3=B8rn
