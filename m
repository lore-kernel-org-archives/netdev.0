From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH next 09/16] drivers/net/wireless: Use static const char *
 const where possible
Date: Tue, 14 Sep 2010 09:12:58 +0200
Message-ID: <AANLkTi=QzToh00xz15mw9+v2YJ5bWigc21S4cGzAQE_X@mail.gmail.com>
References: <cover.1284435709.git.joe@perches.com>
	<ccc9236f25803fbd8bc082e4fef2af8a0885ebf4.1284435710.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37371 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab0INHNA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 03:13:00 -0400
In-Reply-To: <ccc9236f25803fbd8bc082e4fef2af8a0885ebf4.1284435710.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 6:23 AM, Joe Perches <joe@perches.com> wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
> =A0drivers/net/wireless/rt2x00/rt2x00debug.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/=
wireless/rt2x00/rt2x00debug.c
> index b8cf45c..c1710b2 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00debug.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
> @@ -380,7 +380,7 @@ static ssize_t rt2x00debug_read_crypto_stats(stru=
ct file *file,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 loff_t *offset)
> =A0{
> =A0 =A0 =A0 =A0struct rt2x00debug_intf *intf =3D file->private_data;
> - =A0 =A0 =A0 char *name[] =3D { "WEP64", "WEP128", "TKIP", "AES" };
> + =A0 =A0 =A0 static const char * const name[] =3D { "WEP64", "WEP128=
", "TKIP", "AES" };
> =A0 =A0 =A0 =A0char *data;
> =A0 =A0 =A0 =A0char *temp;
> =A0 =A0 =A0 =A0size_t size;
> --
> 1.7.3.rc1
>
>
