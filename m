From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 07:23:45 -0600
Message-ID: <45C9D2E1.7040906@lwfinger.net>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net> <1170850549.6798.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:43370 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161294AbXBGNXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 08:23:48 -0500
In-Reply-To: <1170850549.6798.22.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Tue, 2007-02-06 at 11:39 -0600, Larry Finger wrote:
>> There is a kernel oops on bcm43xx when resuming due to an overly tight timeout loop.
> 
> Come to think of it... Is there any chance of fixing the actual oops
> that happens in this case? I can imagine broken hardware or firmware
> that causes this as well and we don't really want to oops in that case
> either... That's why we have the timeout in the first place, to not hang
> there forever.
> 
> Nothing against this patch though.

As you suggested earlier, a slow clock setting in the bcm43xx device may be the cause of this
difficulty. If my laptop would suspend/resume correctly, then I could test various fixes based on
that hypothesis. Since it does not, I think the band-aid approach is warranted. A proper fix is
still on my agenda; however, getting full data rates still has priority.

Larry
