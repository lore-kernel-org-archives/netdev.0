From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [BUG ?] rtlwifi: rtl8723be: condition with no effect
Date: Sun, 14 Jun 2015 10:17:29 -0500
Message-ID: <557D9B09.7020100@lwfinger.net>
References: <1434192211-5855-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Randy Dunlap <rdunlap@infradead.org>,
	Masanari Iida <standby24x7@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35812 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbFNPRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 11:17:33 -0400
In-Reply-To: <1434192211-5855-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2015 05:43 AM, Nicholas Mc Guire wrote:
> From: Nicholas Mc Guire <hofrat@osadl.org>
>
> scanning for trivial bug-patters with coccinelle spatches returned:
> ./drivers/net/wireless/rtlwifi/rtl8723be/dm.c:886
> 	WARNING: condition with no effect (if branch == else)
>
> Added in 'commit a619d1abe20c ("rtlwifi: rtl8723be: Add new driver")'
>
> drivers/net/wireless/rtlwifi/rtl8723be/dm.c - line numbers from 4.1-rc7
> 886         if (thermalvalue > rtlefuse->eeprom_thermalmeter)
> 887                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
> 888						 	index_for_channel);
> 889         else
> 890                 rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
> 891							index_for_channel);
>
> Can't figure out what the intent of this condition is but it currently has
> no effect as if == else and this most likely is not the intent.

I do not know what the correct code should be here, but I will contact the 
Realtek engineers and get their interpretation. In the meantime, please do not 
change this code.

Thanks,

Larry
