From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] Fix for new version of realtek r8153
Date: Wed, 3 May 2017 09:18:38 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A4BB27@RTITMBSV06.realtek.com.tw>
References: <20170502232048.9153-1-nexussix@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: jake <jake-398iGDqTtD9+pU9mqzGVBQ@public.gmane.org>, nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: jake Briggs <nexussix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "mario_limonciello-8PEkshWhKlo@public.gmane.org" <mario_limonciello-8PEkshWhKlo@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170502232048.9153-1-nexussix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

jake Briggs [mailto:nexussix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
> Sent: Wednesday, May 03, 2017 7:21 AM
[...]
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 07f788c49d57..2a55459fdfac 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -4277,6 +4277,7 @@ static void r8152b_get_version(struct r8152 *tp)
>  		tp->mii.supports_gmii = 1;
>  		break;
>  	case 0x5c30:
> +	case 0x6010:

The two chips are different. I don't think it is a good idea.
Maybe you could use the driver from the Realtek website first.

>  		tp->version = RTL_VER_06;
>  		tp->mii.supports_gmii = 1;
>  		break;
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
