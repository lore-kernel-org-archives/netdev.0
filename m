From: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Subject: Re: [BUG ?] rtlwifi: rtl8723be: condition with no effect
Date: Sun, 14 Jun 2015 17:46:42 +0200
Message-ID: <20150614154642.GA10048@opentech.at>
References: <1434192211-5855-1-git-send-email-hofrat@osadl.org> <557D9B09.7020100@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <557D9B09.7020100-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 14 Jun 2015, Larry Finger wrote:

> On 06/13/2015 05:43 AM, Nicholas Mc Guire wrote:
>> From: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
>>
>> scanning for trivial bug-patters with coccinelle spatches returned:
>> ./drivers/net/wireless/rtlwifi/rtl8723be/dm.c:886
>> 	WARNING: condition with no effect (if branch == else)
>>
>> Added in 'commit a619d1abe20c ("rtlwifi: rtl8723be: Add new driver")'
>>
>> drivers/net/wireless/rtlwifi/rtl8723be/dm.c - line numbers from 4.1-rc7
>> 886         if (thermalvalue > rtlefuse->eeprom_thermalmeter)
>> 887                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
>> 888						 	index_for_channel);
>> 889         else
>> 890                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
>> 891							index_for_channel);
>>
>> Can't figure out what the intent of this condition is but it currently has
>> no effect as if == else and this most likely is not the intent.
>
> I do not know what the correct code should be here, but I will contact 
> the Realtek engineers and get their interpretation. In the meantime, 
> please do not change this code.
>
as noted - I have no clue - so no intent to attempt a change
my mail is only intended as probable bug report.

thx!
hofrat
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
