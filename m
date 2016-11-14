From: "ASIX_Allan [Office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: RE: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Mon, 14 Nov 2016 17:45:28 +0800
Message-ID: <010d01d23e5b$d8993130$89cb9390$@asix.com.tw>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com> <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com> <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com> <00e501d23e54$337d4b70$9a77e250$@asix.com.tw> <f0d21edc-060b-bd9b-fced-faf1f51e8467@nvidia.com>
Reply-To: <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jon Hunter'" <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f0d21edc-060b-bd9b-fced-faf1f51e8467-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jon,

Please help to double check if the USB host controller of your Terga
platform had been powered OFF while running the ax88772_suspend() routine or
not? 

---
Best regards,
Allan Chou


-----Original Message-----
From: Jon Hunter [mailto:jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org] 
Sent: Monday, November 14, 2016 5:34 PM
To: allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org; robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org; freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org;
Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org; Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org;
ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org;
stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org; grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org; changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
andrew-g2DYL2Zd6BY@public.gmane.org; tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org;
linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures

Hi Allan,

On 14/11/16 08:50, ASIX_Allan [Home] wrote:
> It seems the AX88772x dongle had been unexpectedly removed while 
> running the
> ax88772_suspend() routine. If yes, you might see these error messages
> because the hardware had been absent.    

In my case the hardware was never removed. The boards are in a test fixture
that are not touched. This is seen on more than one board. By reverting this
change I no longer see the error messages and appears to be 100%
reproducible.

Jon

--
nvpublic

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
