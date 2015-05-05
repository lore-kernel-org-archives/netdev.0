From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v3] adm8211: fix checkpatch error for trailing
 statements on next line
Date: Mon, 04 May 2015 23:44:58 -0700
Message-ID: <1430808298.7191.1.camel@perches.com>
References: <20150505060150.GA2548@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150505060150.GA2548@bytefire-computer>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-05 at 07:01 +0100, Okash Khawaja wrote:
> This patch fixes the checkpatch.pl error:

Please fix the space/tab use too.

Your email client seems to have converted all the tabs
to spaces.

default should use the same indent as the case statements


> diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
[]
> @@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
>                 pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
>  
>                 switch (cline) {
> -               case  0x8: reg |= (0x1 << 14);
> -                          break;
> -               case 0x16: reg |= (0x2 << 14);
> -                          break;
> -               case 0x32: reg |= (0x3 << 14);
> -                          break;
> -                 default: reg |= (0x0 << 14);
> -                          break;
> +               case  0x8:
> +                       reg |= (0x1 << 14);
> +                       break;
> +               case 0x16:
> +                       reg |= (0x2 << 14);
> +                       break;
> +               case 0x32:
> +                       reg |= (0x3 << 14);
> +                       break;
> +                 default:
> +                       reg |= (0x0 << 14);
> +                       break;
>                 }
>         }
>  

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
