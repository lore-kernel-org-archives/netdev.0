From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: wireless-2.6 git repos broken
Date: Mon, 24 Jul 2006 19:17:43 -0500
Message-ID: <44C56327.2010000@lwfinger.net>
References: <200607231722.39504.mb@bu3sch.de> <44C39B4F.9020002@gentoo.org> <44C39CCD.70702@lwfinger.net> <200607231807.27556.mb@bu3sch.de> <44C3A040.8000206@lwfinger.net> <20060724161441.GA17005@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:63223 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932344AbWGYARk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 20:17:40 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060724161441.GA17005@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sun, Jul 23, 2006 at 11:13:52AM -0500, Larry Finger wrote:
>> Michael Buesch wrote:
>>> On Sunday 23 July 2006 17:59, Larry Finger wrote:
>>>>> Do you have the same problem on other git trees?
>>>>> I saw some people running into this error when cloning Linus' 
>>>>> linux-2.6.git. I couldn't reproduce it, using exactly the same git 
>>>>> version.
>>>> I had the same error when pulling from Linus's tree. It was fixed with a 
>>>> 'git fsck-objects --full' command.
>>> Uhm, that tells me the git tree on kernel.org is broken
>>> and John has to run this command, right?
>>>
>> I think so.
> 
> Hmmm...well, I'll look into it.  FWIW, I cloned my git tree from
> kernel.org onto my laptop while I was at OLS w/o any problems.

There is a thread today on LKML that says that the git server errors out (wrongly) if the download 
does not finish in 10 minutes. That problem is being fixed, but they suggest using rsync protocol to 
clone a large repository.

Michael, is this the cause of your problem?

Larry
