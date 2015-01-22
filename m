From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Thu, 22 Jan 2015 21:58:19 +0100
Message-ID: <54C1646B.4080409@broadcom.com>
References: <54BDCC06.8090107@linux.intel.com> <87twzincvz.fsf@kamboji.qca.qualcomm.com> <54C1012F.1020400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <wens-jdAy2FN1RRM@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54C1012F.1020400-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/22/15 14:54, Sergei Shtylyov wrote:
> Hello.
>
> On 1/22/2015 4:49 PM, Kalle Valo wrote:
>
>>> >From 04d3fa673897ca4ccbea6c76836d0092dba2484a Mon Sep 17 00:00:00 2001
>>> From: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>>> Date: Tue, 20 Jan 2015 11:14:13 +0800
>>> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>
>>> WiFi chip has 2 SDIO functions, and PM core will trigger
>>> twice suspend/resume operations for one WiFi chip to do
>>> the same things. This patch avoid this case.
>
>>> Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>>> Acked-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>>> Acked-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>> Signed-off-by: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>
>> I don't remember giving Acked-by to this (or for matter to anything for
>> a long time). What about Sergei or Arend?
>
> I haven't ACK'ed this patch either.

I did ACK the initial patch and felt it still valid for this 'V2' patch.

Regards,
Arend
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
