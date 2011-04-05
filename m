From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 19/34] rt2x00: Drop __TIME__ usage
Date: Tue, 5 Apr 2011 20:37:53 +0200
Message-ID: <BANLkTimVbujtDnF7uJNgfT-oPYGBfR7WLA@mail.gmail.com>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
	<1302015561-21047-20-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-20-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 5, 2011 at 4:59 PM, Michal Marek <mmarek@suse.cz> wrote:
> The kernel already prints its build timestamp during boot, no need to
> repeat it in random drivers and produce different object files each
> time.
>
> Cc: Ivo van Doorn <IvDoorn@gmail.com>
> Cc: Gertjan van Wingerde <gwingerde@gmail.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
> =A0drivers/net/wireless/rt2x00/rt2x00debug.c | =A0 =A01 -
> =A01 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/=
wireless/rt2x00/rt2x00debug.c
> index c92db32..66166ef 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00debug.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
> @@ -568,7 +568,6 @@ static struct dentry *rt2x00debug_create_file_dri=
ver(const char *name,
> =A0 =A0 =A0 =A0blob->data =3D data;
> =A0 =A0 =A0 =A0data +=3D sprintf(data, "driver:\t%s\n", intf->rt2x00d=
ev->ops->name);
> =A0 =A0 =A0 =A0data +=3D sprintf(data, "version:\t%s\n", DRV_VERSION)=
;
> - =A0 =A0 =A0 data +=3D sprintf(data, "compiled:\t%s %s\n", __DATE__,=
 __TIME__);
> =A0 =A0 =A0 =A0blob->size =3D strlen(blob->data);
>
> =A0 =A0 =A0 =A0return debugfs_create_blob(name, S_IRUSR, intf->driver=
_folder, blob);
> --
> 1.7.4.1
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-kbuild"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
