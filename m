From: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Subject: [BUG ?] rtlwifi: rtl8723be: condition with no effect
Date: Sat, 13 Jun 2015 12:43:31 +0200
Message-ID: <1434192211-5855-1-git-send-email-hofrat@osadl.org>
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>                                      

scanning for trivial bug-patters with coccinelle spatches returned:
./drivers/net/wireless/rtlwifi/rtl8723be/dm.c:886
	WARNING: condition with no effect (if branch == else)

Added in 'commit a619d1abe20c ("rtlwifi: rtl8723be: Add new driver")'

drivers/net/wireless/rtlwifi/rtl8723be/dm.c - line numbers from 4.1-rc7
886         if (thermalvalue > rtlefuse->eeprom_thermalmeter)                  
887                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
888						 	index_for_channel);
889         else
890                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
891							index_for_channel);

Can't figure out what the intent of this condition is but it currently has
no effect as if == else and this most likely is not the intent.

thx!
hofrat
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
