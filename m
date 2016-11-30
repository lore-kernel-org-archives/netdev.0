From: "ASIX_Allan [Office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: RE: [PATCH v4 3/5] net: asix: Fix AX88772x resume failures
Date: Wed, 30 Nov 2016 16:28:25 +0800
Message-ID: <00d601d24ae3$bc68c4a0$353a4de0$@asix.com.tw>
References: <00a601d24ab6$4e9274d0$ebb75e70$@asix.com.tw> <b24b2fa4-88d8-5772-b79c-aa2cadd7aa1e@nvidia.com>
Reply-To: <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jon Hunter'" <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
        <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b24b2fa4-88d8-5772-b79c-aa2cadd7aa1e-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Jon,

Thanks a lot for your reminding. I will submit a new driver patch soon.

---
Best regards,
Allan Chou


-----Original Message-----
From: Jon Hunter [mailto:jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org] 
Sent: Wednesday, November 30, 2016 4:08 PM
To: allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org; freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org; Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org;
Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org;
ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org;
stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org; grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org; changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
andrew-g2DYL2Zd6BY@public.gmane.org; tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org;
linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH v4 3/5] net: asix: Fix AX88772x resume failures

Hi Allan,

On 30/11/16 03:03, ASIX_Allan [Office] wrote:
> The change fixes AX88772x resume failure by
> - Restore incorrect AX88772A PHY registers when resetting
> - Need to stop MAC operation when suspending
> - Need to restart MII when restoring PHY
> 
> Signed-off-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
> Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Tested-by: Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> Tested-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>

V3 of this patch is already in the current mainline branch. So you need to
send a patch on top of V3 (or v4.9-rc7) to get this fixed. Also you should
highlight the fact that this is a fix needed for v4.9.

Cheers
Jon

--
nvpublic

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
