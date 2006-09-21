From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 7/7] d80211: getting wrong freq value if we did hardware
 scan
Date: Thu, 21 Sep 2006 10:42:01 -0700
Message-ID: <4512CEE9.2050106@linux.intel.com>
References: <44F358B8.60700@linux.intel.com> <20060921192934.5260dfdc@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:47462 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751389AbWIURmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 13:42:55 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921192934.5260dfdc@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Mon, 28 Aug 2006 13:57:28 -0700, mabbas wrote:
>   
>> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
>> index a933d92..374193e 100644
>> --- a/net/d80211/ieee80211_sta.c
>> +++ b/net/d80211/ieee80211_sta.c
>> @@ -1543,8 +1543,6 @@ #endif
>>  	bss->channel = channel;
>>  	bss->freq = local->conf.freq;
>>  	if (channel != local->conf.channel &&
>> -	    (local->conf.phymode == MODE_IEEE80211G ||
>> -	     local->conf.phymode == MODE_IEEE80211B) &&
>>  	    channel >= 1 && channel <= 14) {
>>     
>
> The patch doesn't look correct. As I already wrote, no hackish guessing of
> the phymode from channel numbers, please.
>
> Are there any problems with just using rx_status->phymode instead of
> local->conf.phymode (other than "drivers don't set that field" as that can
> be easily fixed)?
>   
Excellent idea here I will fix this patch to use rx_status->phymode if 
set otherwise it will use the default algorithm already exist.
> Thanks,
>
>  Jiri
>
>   
