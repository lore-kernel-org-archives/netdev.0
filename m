From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 13:30:32 -0600
Message-ID: <45A7E1D8.40904@lwfinger.net>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>	<200701121953.44630.mb@bu3sch.de> <4a55afb80701121118r342ec98s8b3312b8c7e59e85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:63249 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964915AbXALTb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 14:31:57 -0500
To: evan foss <evanfoss@gmail.com>
In-Reply-To: <4a55afb80701121118r342ec98s8b3312b8c7e59e85@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

evan foss wrote:
>> This hunk is OK, but I just want to point out that bustype is
>> always equal to BCM43xx_BUSTYPE_PCI ;)
>> The 0x53 timeouts are for an SSB-BUS.
>> So strictly said this hunk is a NOP.
>>
>> The other hunks are OK, too. They fix real bugs.
>> Thanks for spotting them, Larry!
> 
> So then what fixed int's for Stephen Sinclair? Or did they already
> work? I would gladly help test I knew it applied to me.

The lack of int's was due to the bugs mentioned above. His interface didn't work until he applied
the patch, which I hope fixes everyone's PCI-E problems. Please do test.

Larry

