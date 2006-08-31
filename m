From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] WE-21 for bcm43xx (wireless-2.6 git)
Date: Thu, 31 Aug 2006 08:22:22 -0500
Message-ID: <44F6E28E.2080807@lwfinger.net>
References: <44F633F0.7090605@lwfinger.net> <200608311452.46166.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Jean Tourrilhes <jt@hpl.hp.com>,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:27781 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932229AbWHaNW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 09:22:59 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608311452.46166.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 31 August 2006 02:57, Larry Finger wrote:
>>
>> +#if WIRELESS_EXT > 20
>> +#define IW_ESSID_FIX	0
>> +#else
>> +#define IW_ESSID_FIX	1
>> +#endif
> 
> Eh, was this useless #if in the original patch I signed-off, too?
> Because I want to revert my sign-off. :)
> This #if is useless, because we always deal with only one single
> WE version in the kernel. #if WIRELESS_EXT will always be true.
> So remove this and also remove the other #if below.
> 

Yes, it was. I saw this, but left it in because I cannot control the inclusion of the other patch
that brings the NET components up to WE-21, and it seemed that the behavior could be wrong if the
kernel were at WE-20. I'm quite certain that the patch will _NOT_ be included in 2.6.18 as it is
clearly not a bug fix. Once I see WE-21 in the kernel, I'll remove these #ifdef's and eliminate
IW_ESSID_FIX.

If I missed something, please let me know, and I'll resubmit the patch now.

John, have you merged, or do you plan to merge, "[PATCH 2.6.18] WE-21 support (core API)" into
wireless-2.6?

Larry

