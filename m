From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-04-15
Date: Wed, 28 Apr 2010 23:20:52 +0200
Message-ID: <4BD8A6B4.20603@hauke-m.de>
References: <20100415200331.GD3020@tuxdriver.com> <20100415.142907.68448693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100415.142907.68448693.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

in your merge in 5c01d5669356e13f0fb468944c1dd4c6a7e978ad you added "int
i;" into wl1271_main.c which is unused in that function.

This patch fixes the merge problem:

Signed-off-by: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>

--- a/drivers/net/wireless/wl12xx/wl1271_main.c
+++ b/drivers/net/wireless/wl12xx/wl1271_main.c
@@ -1311,7 +1311,6 @@
 	struct wl1271_filter_params *fp;
 	struct netdev_hw_addr *ha;
 	struct wl1271 *wl = hw->priv;
-	int i;

 	if (unlikely(wl->state == WL1271_STATE_OFF))
 		return 0;

David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Thu, 15 Apr 2010 16:03:31 -0400
> 
>> Another fix intended for 2.6.34...without it some firmware wierdness can
>> induce the driver into hanging the box... :-(
>>
>> Please let me know if there are problems!
> 
> Pulled, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
