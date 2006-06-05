From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] Changes to ieee80211.h for user space regulatory daemon
Date: Mon, 05 Jun 2006 16:10:43 -0500
Message-ID: <44849DD3.9000908@lwfinger.net>
References: <447C790E.1030702@lwfinger.net> <20060605185905.GH6068@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:55179 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750855AbWFEVKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 17:10:46 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
In-Reply-To: <20060605185905.GH6068@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
>> @@ -968,6 +968,7 @@ #define IEEE80211_52GHZ_CHANNELS (IEEE80
>>
>>  enum {
>> 	IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
>> +	IEEE80211_CH_80211H_RULES = (1 << 1),
>> 	IEEE80211_CH_B_ONLY = (1 << 2),
>> 	IEEE80211_CH_NO_IBSS = (1 << 3),
>> 	IEEE80211_CH_UNIFORM_SPREADING = (1 << 4),
> 
> Any idea why this "hole" was here to begin with?  Was there something
> else defined as (1 << 1) previously?  Is it safe to reuse this value?
> 
> John

The hole has been there as long as I have been reading the ieee80211 code. If you are not 
comfortable with plugging the hole, then we can use (1 << 5).

Larry

