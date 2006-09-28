From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 10:52:24 -0500
Message-ID: <451BEFB8.8000402@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain> <451BE74F.3010908@lwfinger.net> <200609281135.24720.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Michael Buesch <mb@bu3sch.de>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:38118 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751201AbWI1Pwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:52:40 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200609281135.24720.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> On Thursday 28 September 2006 11:16, Larry Finger wrote:
>> First of all, my problem is quite likely caused by a buggy AP. It is a
>> Linksys WRT54G V5, which is one of those with a VxWorks kernel, not Linux.
>> I have already reported one bug to Linksys, which they have neither
>> acknowledged nor fixed! In that case, SoftMAC had to be modified as a
>> work-around.
>>
> These APs are truly bad. Hacking linux into it (DD-WRT) helps a bit, but 
> wireless often seems to fail *completely* at times.

I had very good luck with my first AP, a Linksys WRT54G V1, that I bought a second when the power 
supply failed in the first. Little did I know that a VxWorks license costs less than the extra 
memory needed to run Linux. Or was it to defeat the open-source alternatives for the AP?

>> I don't know why the deauthentication is being sent. The reason is not
>> logged, which will be my first change in the code. The second place to look
>> is why SoftMAC reports the network is unknown when the MAC printed is that
>> of my AP.
>>
> The deauth reason code is usually 6 or 7.. IIRC, it is 6: Class 2 Frame from 
> Non Authenticated STA. The AP just forgets you're associated. However, I 
> think that was from when I had a v3 WRT54G.

I already have modified SoftMAC to log the reason. Now I have to wait for the event to happen.

> I made sure the old adm8211 softmac stack had a very good set of printks to 
> report these sort of things. :) Many APs do funny things..

Thanks for the tip. It is unfortunate that the Linux code has to work around all the closed-source 
other stuff!


Larry
