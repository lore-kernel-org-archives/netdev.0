From: Joseph Jezak <josejx@gentoo.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 09 Feb 2007 14:55:29 -0500
Message-ID: <45CCD1B1.80709@gentoo.org>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>	<45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org> <200702092017.36950.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Larry Finger <larry.finger@lwfinger.net>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc14.comcast.net ([216.148.227.154]:41847 "EHLO
	rwcrmhc14.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992774AbXBITzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 14:55:32 -0500
In-Reply-To: <200702092017.36950.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Friday 09 February 2007 20:05, Joseph Jezak wrote:
>>> I'll agree to that as long as there is a clear indication of any differences between V3 and V4 firmware.
>> That's also part of the problem.  With the v4 driver, Broadcom 
>> dropped support for a number of older BPHY devices (4301/4303 and 
>> some 4306 revisions).  Do we still want to support those?  Should I 
>> continue writing the specs for the uCode revision it's based on or 
>> should I combine them?
> 
> If it's easily possible, please try to combine the old stuff
> with the new v4 specs.
> I think it's basically only dropped if() branches, right?
> 

Well, here's the problem.  There are a few places where a value is 
changed (different value written to a register).  Does this mean 
that the value is different due to the uCode changes (can't tell, no 
documentation)?  Is it applicable to all revisions (can't tell, some 
revisions are not supported in this version)?  If the revision 
number range in a check changes is that because of a difference in 
supported cards or a bug fix?

So, it's not as simple as just dropped if() branches.  I can do my 
best to combine them (I have done some of this already), but I can't 
promise that it'll be accurate for all revisions or versions of the 
chipset.

-Joe
