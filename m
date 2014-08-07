From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] 6lowpan: Allow 6LoWPAN to be
	modular
Date: Thu, 7 Aug 2014 11:31:11 -0700
Message-ID: <144B79BA-C835-4EF4-8FF5-533D535A5143@holtmann.org>
References: <1407424003-15073-1-git-send-email-geert@linux-m68k.org>
	<ABE15994-F47B-4E4B-A6FC-79C6BCAC9FF3@holtmann.org>
	<CAMuHMdU214_aDNQBH=Nk6DZwsdCB3FQY1DY0ZQ8WQGQ86dGFUQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAMuHMdU214_aDNQBH=Nk6DZwsdCB3FQY1DY0ZQ8WQGQ86dGFUQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Geert,

>>> Change config symbol 6LOWPAN from type bool to type tristate, so
>>> 6LoWPAN can be built modular, just like IPV6
>>> 
>>> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
>>> ---
>>> net/6lowpan/Kconfig | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>> 
>>> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
>>> index 028a5c6d1f61..e4a02ef55102 100644
>>> --- a/net/6lowpan/Kconfig
>>> +++ b/net/6lowpan/Kconfig
>>> @@ -1,5 +1,5 @@
>>> config 6LOWPAN
>>> -     bool "6LoWPAN Support"
>>> +     tristate "6LoWPAN Support"
>> 
>> is this a regression from the previous CONFIG_6LOWPAN separation that we introduced? If it is, then it might be easiest if Dave just takes it into his net tree. Otherwise I take it through bluetooth-next.
> 
> I hadn't thought about that... Checking...
> 
> Yes, I believe this is a regression.
> 
> In v3.16, my allmodconfig build had:
> 
> CONFIG_IEEE802154_6LOWPAN=m
> CONFIG_6LOWPAN_IPHC=m
> CONFIG_BT_6LOWPAN=y
> 
> Without my patch it has:
> 
> CONFIG_6LOWPAN=y
> CONFIG_IEEE802154_6LOWPAN=m
> CONFIG_BT_6LOWPAN=m
> 
> and iphc is what's in net/6lowpan/built-in.o now.

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Dave, I am fine if you just queue this up for 3.17-rc1.

Regards

Marcel


------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
