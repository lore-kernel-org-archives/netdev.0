From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 28 Mar 2007 18:42:45 -0400
Message-ID: <460AEF65.8070908@pobox.com>
References: <20070325145810.GI16477@stusta.de> <460AE997.90509@tmr.com> <460AEB85.1020101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Davidsen <davidsen@tmr.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48433 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933814AbXC1Wm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 18:42:58 -0400
In-Reply-To: <460AEB85.1020101@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Bill Davidsen wrote:
>> Adrian Bunk wrote:
>>> This patch contains the scheduled removal of the eepro100 driver.
>>>
>>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>>>
>>>
>> This keeps coming around, but I haven't seen an answer to the 
>> questions raised by Eric Piel or Kiszka. I do know that e100 didn't 
>> work on some IBM rackmount servers and eepro100 did, but since I'm no 
>> longer responsible for those machines I can't retest. Perhaps someone 
>> will be able to provide data points.
>>
>> IBM current offerings as of about three years ago, I had a few dozen 
>> of them at one time.
> 
> We have provided a (test) driver which allows e100 to use IO to 
> communicate with the device, which seems to have helped for one person. 
> I think we need to work with those changes and see if it helps the other 
> people resolve their e100 issues. Unfortunately it keeps slipping off to 
> the low priority list for us.
> 
> I suggest that we should push this code into -mm for people to test or 
> something. It's fairly low risk as by default the patch won't enable IO 
> and thus use the old method of writing to the adapter.

Sounds sane to me.  My overall opinion on eepro100 removal is that we're 
not there yet.  Rare problem cases remain where e100 fails but eepro100 
works, and it's older drivers so its low priority for everybody.

Needs to happen, though...

	Jeff



