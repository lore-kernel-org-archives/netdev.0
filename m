From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] remove dead code from bcm43xx-softmac
Date: Mon, 04 Sep 2006 08:16:19 -0500
Message-ID: <44FC2723.2090406@lwfinger.net>
References: <44FBADE0.3010905@lwfinger.net> <200609040851.01338.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <st3@riseup.net>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:26279 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964908AbWIDNQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 09:16:27 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609040851.01338.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Monday 04 September 2006 06:38, Larry Finger wrote:
>> John,
>>
>> Please queue the following patch for wireless-2.6. It removes some code that was made obsolete by 
>> the wireless statistics changes of several weeks ago, but was not noticed them.
>>
>> Thanks,
>>
>> Larry
>>
>> =================
>>
>> This patch removes code that was make obsolete when the wireless statistics in bcm43xx-softmac were 
>> changed, but was overlooked at that time. The value of bcm->stats.link_quality computed here is 
>> never used.
> 
> So you can also remove the actual variable, no?

Yes.

Larry

