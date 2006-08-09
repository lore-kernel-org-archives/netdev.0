From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/8] d80211/bcm43xx: Modify struct ieee80211_rx_status
 for wireless statistics.
Date: Wed, 09 Aug 2006 10:21:16 -0500
Message-ID: <44D9FD6C.9030006@lwfinger.net>
References: <44D92535.8090303@lwfinger.net> <1155133346.3615.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:61316 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750972AbWHIPVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 11:21:17 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155133346.3615.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Tue, 2006-08-08 at 18:58 -0500, Larry Finger wrote:
>>
>> diff --git a/include/net/d80211.h b/include/net/d80211.h
>> index ba5cb4c..8479b58 100644
>> --- a/include/net/d80211.h
>> +++ b/include/net/d80211.h
>> @@ -205,6 +205,9 @@ struct ieee80211_rx_status {
>>           int channel;
>>           int phymode;
>>           int ssi;
>> +	int maxssi;
>> +	int signal;
>> +	int noise;
> 
> Spacing?  Looks like you're using real tabs here, but the current code
> uses 8 spaces instead.  Not sure if that's a problem.

I am using tabs, which I think is the preferred way. I also remember that the 
rule is not to change the white space on things you are not touching. Is that 
correct?

Larry

