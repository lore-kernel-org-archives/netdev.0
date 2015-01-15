From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Thu, 15 Jan 2015 14:52:09 +0200
Message-ID: <877fwotddy.fsf@kamboji.qca.qualcomm.com>
References: <54B36C88.3030609@linux.intel.com> <54B39B59.8000907@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Fu\, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <wens-jdAy2FN1RRM@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54B39B59.8000907-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> (Arend van Spriel's message of
	"Mon, 12 Jan 2015 11:00:57 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:

> On 01/12/15 07:41, Fu, Zhonghui wrote:
>>  From 8685c3c2746b4275fc808d9db23c364b2f54b52a Mon Sep 17 00:00:00 2001
>> From: Zhonghui Fu<zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>> Date: Mon, 12 Jan 2015 14:25:46 +0800
>> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>>
>> WiFi chip has 2 SDIO functions, and PM core will trigger
>> twice suspend/resume operations for one WiFi chip to do
>> the same things. This patch avoid this case.
>>
>> Acked-by: Arend van Spriel<arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Acked-by: Sergei Shtylyov<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>> Signed-off-by: Zhonghui Fu<zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>
> This patch needs to be rebased.
>
> Kalle,
>
> Please drop this one.

Ok, dropped. I'll wait for the rebase.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
