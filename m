From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 12:40:08 -0500
Message-ID: <451C08F8.5040201@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <20060928163135.GH8121@knob.reflex> <451C0090.10109@lwfinger.net> <200609281914.17041.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, linville@tuxdriver.com,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	Jason Lunz <lunz@falooley.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:34489 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030319AbWI1RkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:40:16 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609281914.17041.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 28 September 2006 19:04, Larry Finger wrote:
>> Jason Lunz wrote:
>>> On Thu, Sep 28, 2006 at 10:52:24AM -0500, Larry Finger wrote:
>>>> I had very good luck with my first AP, a Linksys WRT54G V1, that I
>>>> bought a second when the power supply failed in the first. Little did
>>>> I know that a VxWorks license costs less than the extra memory needed
>>>> to run Linux. Or was it to defeat the open-source alternatives for the
>>>> AP?
>>> last I checked, linksys (cisco?) still sells the linux-compatible
>>> version as the WRT54GL. <- note the extra 'L'.
>> I know, but have decided to stay with V5 (and bitch a lot) as others are likely to suffer from the 
>> same problems as I do. As many of them would never try alternate firmware, we need to provide the 
>> workarounds. If I'm using one of the brain-dead APs, I get the symptoms first hand and can tell when 
>> they are fixed.
> 
> Well. You say that it works with your AP and without my patch, but
> not with the patch. I'd say it works by pure luck. I don't think
> my patch changes any semantics. It just properly protects some
> parts from racing. Maybe you actually benefit from these races
> and softmac magically "races you the correct result" ;)
> 
> Or do you notice something that changes semantics?
> 

No, only that the system recovers w/o your patch, and not with it. It could very well race to the 
correct point. ATM, I have your patch back in and I'm trying to get more diagnostics in the logs. 
I'll let you know.

Larry

