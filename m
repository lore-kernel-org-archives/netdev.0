From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/3] hostap: Delete an unnecessary jump label in prism2_ioctl_priv_hostapd()
Date: Sun, 21 Aug 2016 11:45:13 +1000
Message-ID: <CAGRGNgW3tCpLqs56DXW65_Du8HD+oYt-St3Oc6C6WLeungM51g@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net> <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
 <65ed528f-7ec5-a0f2-6219-3e63a78ca0ee@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
        Kalle Valo <kvalo@codeaurora.org>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <65ed528f-7ec5-a0f2-6219-3e63a78ca0ee@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcus,

On Sun, Aug 21, 2016 at 2:46 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 Aug 2016 18:21:29 +0200
>
> Remove a jump label which is unneeded in this function at the end.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/wireless/intersil/hostap/hostap_ioctl.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
> index 4e271f9..5942917 100644
> --- a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
> +++ b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
> @@ -3835,14 +3835,12 @@ static int prism2_ioctl_priv_hostapd(local_info_t *local, struct iw_point *p)
>         }
>
>         if (ret == 1 || !ap_ioctl) {
> -               if (copy_to_user(p->pointer, param, p->length)) {
> +               if (copy_to_user(p->pointer, param, p->length))
>                         ret = -EFAULT;
> -                       goto out;
> -               } else if (ap_ioctl)
> +               else if (ap_ioctl)
>                         ret = 0;
>         }
>
> - out:

Does this change make any difference to the compiled code?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
