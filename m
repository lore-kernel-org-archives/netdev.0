From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 13:01:25 -0500
Message-ID: <4CC5C5F5.3080607@lwfinger.net>
References: <902045.66378.qm@web29504.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Serafeim Zanikolas <sez-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>, herton-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <902045.66378.qm-gyycVyw5OoDyX4RqAA4FmIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/25/2010 10:39 AM, Hin-Tak Leung wrote:
> 
> okay - sorry about the confusion - I was grep'ing for GFP_DMA and only b43/b43lagacy have it and it is relatively rare. AFAIK none of the rtl8187 devices are non-USB... probably a NACK then, but I should ask Serafeim if there is a reason for him to submit this patch? (other than "it says dma"...) 

There are some devices driven by b43/b43legacy that implement only 24-bit DMA.
For that reason, they need to allocate DMA buffers in the low 16 MB of RAM. For
rtl8187, that consideration does not apply.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
