From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2] net/wireless: enable wiphy device to suspend/resume
 asynchronously
Date: Wed, 23 Sep 2015 13:07:43 +0800
Message-ID: <5602339F.1010301@linux.intel.com>
References: <55FCCB0E.3000807@linux.intel.com> <1442930747.2018.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1442930747.2018.12.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi johannes,

Could you please tell me which kernel version will merge this patch?


Thanks,
Zhonghui

 
On 2015/9/22 22:05, Johannes Berg wrote:
> On Sat, 2015-09-19 at 10:40 +0800, Fu, Zhonghui wrote:
>> Now, PM core supports asynchronous suspend/resume mode for devices
>> during system suspend/resume, and the power state transition of one
>> device may be completed in separate kernel thread. PM core ensures
>> all power state transition timing dependency between devices. This
>> patch enables wiphy device to suspend/resume asynchronously. This can
>> take advantage of multicore and improve system suspend/resume speed.
>>
> Applied.
>
> johannes
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
