From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v3 4/4] ath9k:  Support ethtool getstats api.
Date: Tue, 20 Mar 2012 09:47:38 -0700
Message-ID: <4F68B4AA.3070306@candelatech.com>
References: <1332183105-4447-1-git-send-email-greearb@candelatech.com> <1332183105-4447-4-git-send-email-greearb@candelatech.com> <4F684301.9040006@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47958 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab2CTQrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 12:47:42 -0400
In-Reply-To: <4F684301.9040006@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2012 01:42 AM, Florian Fainelli wrote:
> Hi,
>
> Le 03/19/12 19:51, greearb@candelatech.com a =C3=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This returns many of the values that formerly could
>> only be obtained from debugfs. This should be an
>> improvement when trying to access these counters
>> programatically. Currently this support is only
>> enabled when DEBUGFS is enabled because otherwise
>> these stats are not accumulated.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>>
>> v3: No changes from v2
>>
>> :100644 100644 4a00806... 7261f88... M drivers/net/wireless/ath/ath9=
k/main.c
>> drivers/net/wireless/ath/ath9k/main.c | 134 ++++++++++++++++++++++++=
+++++++++
>> 1 files changed, 134 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wir=
eless/ath/ath9k/main.c
>> index 4a00806..7261f88 100644
>> --- a/drivers/net/wireless/ath/ath9k/main.c
>> +++ b/drivers/net/wireless/ath/ath9k/main.c
>> @@ -2430,6 +2430,134 @@ static int ath9k_get_antenna(struct ieee8021=
1_hw *hw, u32 *tx_ant, u32 *rx_ant)
>> return 0;
>> }
>>
>> +#ifdef CONFIG_ATH9K_DEBUGFS
>
> These are ethtool knobs, so you might want to introduce a new config =
symbol dedicated to it, which depends on CONFIG_ATH9K_DEBUGFS eventuall=
y.

I'd like to gather at least most stats always, so ethtool can work rega=
rdless of
debugfs.  But, that can be follow on patches in my opinion.  If it turn=
s out
that we need another config option for this, then that is fine too.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
