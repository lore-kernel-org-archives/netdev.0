From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 2/2] adm8211: fix the possible pci cache line sizes inside switch-case
Date: Wed, 06 May 2015 07:59:04 +0300
Message-ID: <87wq0ms3mv.fsf@kamboji.qca.qualcomm.com>
References: <20150505224020.GA3805@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150505224020.GA3805@bytefire-computer> (Okash Khawaja's
	message of "Tue, 5 May 2015 23:40:20 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> The PCI cache line size value was being compared against decimal values prefixed with 0x.
>
> Fixed the literals to use the correct hex values.
>
>
> Signed-off-by: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

[...]

> @@ -1101,10 +1101,10 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
>  		case  0x8:
>  			reg |= (0x1 << 14);
>  			break;
> -		case 0x16:
> +		case 0x10:
>  			reg |= (0x2 << 14);
>  			break;
> -		case 0x32:
> +		case 0x20:
>  			reg |= (0x3 << 14);
>  			break;
>  		default:

Did you test this? How certain can we be that this doesn't break
anything?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
