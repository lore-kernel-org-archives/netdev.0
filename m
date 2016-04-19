From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] rtl8xxxu: hide unused tables
Date: Tue, 19 Apr 2016 19:01:13 +0300
Message-ID: <87mvopy4dy.fsf@purkki.adurom.net>
References: <1461016782-2640046-1-git-send-email-arnd@arndb.de>
	<wrfjzisp64d7.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Jakub Sitnicki <jsitnicki@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <wrfjzisp64d7.fsf@redhat.com> (Jes Sorensen's message of "Tue, 19
	Apr 2016 10:49:08 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jes Sorensen <Jes.Sorensen@redhat.com> writes:

> Arnd Bergmann <arnd@arndb.de> writes:
>> The references to some arrays in the rtl8xxxu driver were moved inside
>> of an #ifdef, but the symbols remain outside, resulting in build warnings:
>>
>> rtl8xxxu/rtl8xxxu.c:1506:33: error: 'rtl8188ru_radioa_1t_highpa_table' defined but not used
>> rtl8xxxu/rtl8xxxu.c:1431:33: error: 'rtl8192cu_radioa_1t_init_table' defined but not used
>> rtl8xxxu/rtl8xxxu.c:1407:33: error: 'rtl8192cu_radiob_2t_init_table' defined but not used
>> rtl8xxxu/rtl8xxxu.c:1332:33: error: 'rtl8192cu_radioa_2t_init_table' defined but not used
>> rtl8xxxu/rtl8xxxu.c:239:35: error: 'rtl8192c_power_base' defined but not used
>> rtl8xxxu/rtl8xxxu.c:217:35: error: 'rtl8188r_power_base' defined but not used
>>
>> This adds an extra #ifdef around them to shut up the warnings.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Fixes: 2fc0b8e5a17d ("rtl8xxxu: Add TX power base values for gen1 parts")
>> Fixes: 4062b8ffec36 ("rtl8xxxu: Move PHY RF init into device specific functions")
>> ---
>>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>
> I'll apply it to my tree!

Actually I would prefer to apply this directly to wireless-drivers-next
so that the warnings are quickly fixed.

-- 
Kalle Valo
