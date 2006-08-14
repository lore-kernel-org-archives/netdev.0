From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: network manager confused with bcm43xx-d80211?
Date: Mon, 14 Aug 2006 07:48:22 -0500
Message-ID: <44E07116.6060208@lwfinger.net>
References: <44E02F41.2060300@sipsolutions.net> <44E031D2.8070106@sipsolutions.net> <1155556011.2885.3.camel@localhost.localdomain> <44E06C8B.1040400@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Michael Buesch <mbuesch@freenet.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:61395 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750716AbWHNMsW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 08:48:22 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E06C8B.1040400@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Dan Williams wrote:
> Yeah, I noticed it wasn't in /proc/net/wireless. Should've tipped me off 
> I guess. And I probably also should've thought that nm would ask HAL. 
> Looks like I wasn't really on track when I wrote this yesterday ;)
>> So if the wlanX interface isn't in /proc/net/wireless, you lose.  I
>> think we discussed this in the private rt2x00 thread about a month ago?
>> Some patches came out of that one, specifically the SET_NETDEV_DEV ones
>> for rt2x00 and d80211.  The problem with d80211 was that it didn't
>> implement the get_wireless_stats() handler function, and that function
>> (I think?) is the one that lets the wlanX device show up
>> in /proc/net/wireless.
>>   
> Yeah, that sounds about right. Larry, do you remember/know more about 
> this? I think you were working in this area?

Yes, get_wireless_stats is needed for the device to show up in /proc/net/wireless.

The RFCd patch to add wireless stats to d80211 received only minor comments, 
which have all been addressed. I will be submitting a proper patch to Linville's 
tree today. In addition, I have reached an agreement with the authors of all 
other drivers that use d80211 on a scheme that will implement the stats code for 
them as well. Unfortunately, none of them provide such useful quantities as 
noise values, but perhaps the prominent FIXMEs will spur action by those who 
have detailed device specifications.

Larry
