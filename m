From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/1] linux-wireless: Added psk in struct cfg80211_connect_params
 needed for offloading 4way handshake to driver
Date: Tue, 11 Nov 2014 11:35:42 +0100
Message-ID: <5461E67E.7010408@broadcom.com>
References: <DF163EE1A432BF4BBE6B2088220663A67437BD@SJEXCHMB06.corp.ad.broadcom.com>	 <1415698161.2163.0.camel@sipsolutions.net> <5461DCC9.5050702@broadcom.com> <1415700220.2163.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Gautam (Gautam Kumar) Shukla" <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jithu Jance <jithu-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Sreenath S <sreenats-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Vladimir Kondratiev <vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415700220.2163.3.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-11-14 11:03, Johannes Berg wrote:
> On Tue, 2014-11-11 at 10:54 +0100, Arend van Spriel wrote:
> 
>>> Also, there's a competing approach from QCA that's far more suited.
>>
>> I probably was not paying attention to it, but would you have a
>> reference to this.
> 
> ... digs around in email ...
> 
> http://mid.gmane.org/1343907187-6686-1-git-send-email-qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
> 
> Anyway, looking back at that, it wasn't really all that different, just
> a bit more complete maybe.

Read through the whole thread. It seems some comments from you needed to
be addressed and Vladimir wanted to evaluate it. So that was the end of
the thread.

What did pop up is the wiphy flags vs. nl80211 feature flags. When that
comes up it looks like 'potAtoes, potaetoes' to me.

So is there are clear design rule for when to use which flag. For me the
wiphy object represents the device/firmware and 4-way handshake offload
support is determined by what the device/firmware supports.

Regards,
Arend

> johannes
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
