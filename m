From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] net: remove LLTX in atl2 driver
Date: Thu, 25 Sep 2008 21:24:35 -0400
Message-ID: <48DC39D3.3090400@redhat.com>
References: <1222302922-13200-1-git-send-email-kexin.hao@windriver.com>	 <48DBF4DD.8060908@redhat.com> <48DBFAB5.2010709@garzik.org>	 <48DC11F5.20900@redhat.com>  <20080925185849.0df482e2@osprey.hogchain.net> <1222392042.2682.40.camel@kevin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Jeff Garzik <jeff@garzik.org>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kevin Hao <kexin.hao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50873 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbYIZB1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 21:27:24 -0400
In-Reply-To: <1222392042.2682.40.camel@kevin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Hao wrote:
> On Thu, 2008-09-25 at 18:58 -0500, Jay Cliburn wrote:
>> On Thu, 25 Sep 2008 18:34:29 -0400
>> Chris Snook <csnook@redhat.com> wrote:
>>
>>> I'm all in favor of removing legacy cruft.  I want to know a little
>>> more about it so we can remove it from the atl1 code as well.
>>> Ultimately most of this will be shared code.
>> Yes, LLTX can (and should) be removed from the atl1 code.  I had an
>> exchange with Herbert Xu and David Miller on LKML a few weeks ago, and
>> they gave me a few tips on how to do it, but I haven't yet had the
>> time.  What takes an experienced netdev warrior about a half hour to
>> implement unfortunately takes me days of after-dayjob time as I track
>> through all the calls that that are affected and test the modified
>> driver.
>>
>> Now back to atl2...  I'd like to hear from Kevin also whether he tested
>> the LLTX removal.  I'm building the driver with his patch as we speak,
>> and I'll test it myself this weekend, but Kevin I'd still like to know
>> if you tested the patch.
> 
> Yes, I have tested this driver on a Eee PC. It works well.

Thanks, please mention this with your patch submissions.

-- Chris
