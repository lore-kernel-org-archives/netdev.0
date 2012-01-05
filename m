From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump()
 into functions
Date: Thu, 5 Jan 2012 10:22:32 +0200
Message-ID: <4F055DC8.9050902@qca.qualcomm.com>
References: <20120104230429.32306.75965.stgit@x201>	 <20120104230950.32306.21264.stgit@x201> <1325720472.4116.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ath6kl-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1325720472.4116.7.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/05/2012 01:41 AM, Joe Perches wrote:
> On Thu, 2012-01-05 at 01:09 +0200, Kalle Valo wrote:
>> That way it's possible to not export debug_mask outside the upcoming
>> ath6kl_core.ko and that makes it easier to ath6kl_core.ko in the
>> following patch.
> []
>> Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> []
>> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
> []
>> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
>> +{
>> +	va_list args;
>> +
>> +	if (!(debug_mask & mask))
>> +		return;
>> +
>> +	va_start(args, fmt);
>> +	ath6kl_printk(KERN_DEBUG, fmt, &args);
> 
> Passing a va_list as an argument?
> I believe this doesn't work.

Doh, I was supposed to test this but then I forgot in the hurry. Thanks
for pointing this out. I will send v2 which will fix this.

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
