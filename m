From: Tomi Orava <tomimo@ncircle.nullnet.fi>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Fri, 20 Mar 2009 05:59:05 +0200
Message-ID: <49C31489.6080206@ncircle.nullnet.fi>
References: <bug-12886-10286@http.bugzilla.kernel.org/> <200903181614.08724.rjw@sisk.pl> <49C2719A.8080905@ncircle.nullnet.fi> <200903192159.13170.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:60202 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbZCTD7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 23:59:14 -0400
In-Reply-To: <200903192159.13170.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2009 10:59 PM, Rafael J. Wysocki wrote:
> On Thursday 19 March 2009, Tomi Orava wrote:
>> Hi,
>>
>>> Hm, are you sure the commit in question _is_ in 2.6.28.y?  I can't see it in
>>> there.  It is in the current Linus' tree, but not in v2.6.28 and surely not in
>>> -stable.  Do you use a distro kernel?
>> Ok, I've now verified that I did indeed mess up with the commit
>> mentioned previously. In other words the stable series 2.6.28.x
>> doesn't support the suspend feature on my Asus A7V880 at all.
>> The bios option is not respected at all and the command
>> 'ethtool -s eth0 wol g' doesn't enable the suspend any better.
>>
>> However, the commit taken from main branch actually makes also
>> the stable series to work with this motherboard. No additional
>> changes are needed, it just works out of the box.
>>
>> Sorry about the mess up.
> 
> No problem.
> 
> Does it mean we can close the bug?

Yes, as it does look like the next stable release should
contain the fix by default.

Thanks & Regards,
Tomi Orava
