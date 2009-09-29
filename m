From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: b43 is broken in latest net-2.6 and linux-2.6
Date: Tue, 29 Sep 2009 09:13:39 +0200
Message-ID: <4AC1B3A3.4050205@hartkopp.net>
References: <4AB4BF1F.7070501@hartkopp.net> <20090928184211.GC4737@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:32789 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbZI2HNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 03:13:43 -0400
In-Reply-To: <20090928184211.GC4737@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John W. Linville wrote:
> On Sat, Sep 19, 2009 at 01:23:11PM +0200, Oliver Hartkopp wrote:
>> Hello Michael,
>>
>> my b43 wireless card (Dell 830) is not working with the latest net-2.6 (and
>> also linux-2.6 2.6.31-05767-gdf58bee).
>>
>> net-2.6 2.6.31-03263-gc29854e is working
>> net-2.6 2.6.31-03301-ga97e178 is broken
>>
>> I removed the patch with the work_queue stuff which did not help - so it's
>> probably the other patch you added to b43 recently.
>>
>> Don't know ... the wlan0 link does not become ready anymore.
>>
>> If you need some more information - please let me know.
> 
> Is this working better now, with 2.6.31-rc1?

Thanks for coming back on this.

Yes it is fixed now.

   'cfg80211: fix SME connect'

broke it and

   'cfg80211: don't overwrite privacy setting'

fixed it afterwards (at least in my setup).

So it's pretty well working now.

Best regards,
Oliver
