From: Daniel Drake <dsd@gentoo.org>
Subject: Re: wireless-2.6 git repos broken
Date: Sun, 23 Jul 2006 16:52:47 +0100
Message-ID: <44C39B4F.9020002@gentoo.org>
References: <200607231722.39504.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Junio C Hamano <junkio@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:41791 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751230AbWGWPp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 11:45:28 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607231722.39504.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> mb@ppc1:/tmp$ git --version
> git version 1.4.1
> mb@ppc1:/tmp$ git clone  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> Generating pack...
> Done counting 290305 objects.
> Deltifying 290305 objects.
>  100% (290305/290305) done
> fatal: unexpected EOF)      
> fatal: packfile '/tmp/wireless-2.6/.git/objects/pack/tmp-DuBFrs' SHA1 mismatch
> error: git-fetch-pack: unable to read from git-index-pack
> error: git-index-pack died with error code 128
> fetch-pack from 'git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git' failed.
> 
> I tried several times on two different machines and also (as you can see)
> with different git versions.
> Could it be a git bug?

Do you have the same problem on other git trees?
I saw some people running into this error when cloning Linus' 
linux-2.6.git. I couldn't reproduce it, using exactly the same git version.

Daniel
