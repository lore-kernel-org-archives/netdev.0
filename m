From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: wireless-2.6 git repos broken
Date: Sun, 23 Jul 2006 10:59:09 -0500
Message-ID: <44C39CCD.70702@lwfinger.net>
References: <200607231722.39504.mb@bu3sch.de> <44C39B4F.9020002@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Junio C Hamano <junkio@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:37287 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751244AbWGWP7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 11:59:19 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <44C39B4F.9020002@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Michael Buesch wrote:
>> mb@ppc1:/tmp$ git --version
>> git version 1.4.1
>> mb@ppc1:/tmp$ git clone  
>> git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
>> Generating pack...
>> Done counting 290305 objects.
>> Deltifying 290305 objects.
>>  100% (290305/290305) done
>> fatal: unexpected EOF)      fatal: packfile 
>> '/tmp/wireless-2.6/.git/objects/pack/tmp-DuBFrs' SHA1 mismatch
>> error: git-fetch-pack: unable to read from git-index-pack
>> error: git-index-pack died with error code 128
>> fetch-pack from 
>> 'git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git' 
>> failed.
>>
>> I tried several times on two different machines and also (as you can see)
>> with different git versions.
>> Could it be a git bug?
> 
> Do you have the same problem on other git trees?
> I saw some people running into this error when cloning Linus' 
> linux-2.6.git. I couldn't reproduce it, using exactly the same git version.

I had the same error when pulling from Linus's tree. It was fixed with a 'git fsck-objects --full' 
command.

Larry
