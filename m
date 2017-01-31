From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4.10-rc3 09/13] iscsi: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Tue, 31 Jan 2017 19:32:10 +0000
Message-ID: <1485891116.3113.2.camel@sandisk.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
         <E1cYdxN-0000Wr-AS@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
To: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org" <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1cYdxN-0000Wr-AS-eh5Bv4kxaXIk46pC+1QYvQNdhmdF6hFW@public.gmane.org>
Content-Language: en-US
Content-ID: <C15BF99F1975BB4F8A878C6D0FDBB237-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-01-31 at 19:19 +0000, Russell King wrote:
> drivers/target/iscsi/iscsi_target_login.c:1135:7: error: implicit declara=
tion of function 'try_module_get' [-Werror=3Dimplicit-function-declaration]
>=20
> Add linux/module.h to iscsi_target_login.c.
>=20
> Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
> ---
>  drivers/target/iscsi/iscsi_target_login.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/i=
scsi/iscsi_target_login.c
> index 450f51deb2a2..eab274d17b5c 100644
> --- a/drivers/target/iscsi/iscsi_target_login.c
> +++ b/drivers/target/iscsi/iscsi_target_login.c
> @@ -17,6 +17,7 @@
>   ***********************************************************************=
*******/
> =20
>  #include <crypto/hash.h>
> +#include <linux/module.h>
>  #include <linux/string.h>
>  #include <linux/kthread.h>
>  #include <linux/idr.h>

Reviewed-by: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>=
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
