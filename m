From: Michael Buesch <mb@bu3sch.de>
Subject: wireless-2.6 git repos broken
Date: Sun, 23 Jul 2006 17:22:38 +0200
Message-ID: <200607231722.39504.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Junio C Hamano <junkio@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27093
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751227AbWGWPXe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 11:23:34 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

I would say something is broken in the wireless-2.6 git repository.
When I try to clone the tree, I get this error:

mb@ppc1:/tmp$ git --version
git version 1.2.3
mb@ppc1:/tmp$ git clone  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
fatal: packfile '/tmp/wireless-2.6/.git/objects/pack/tmp-ABKsAK' SHA1 mismatch
error: git-clone-pack: unable to read from git-index-pack
error: git-index-pack died with error code 128
clone-pack from 'git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git' failed.


mb@ppc1:/tmp$ git --version
git version 1.4.1
mb@ppc1:/tmp$ git clone  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
Generating pack...
Done counting 290305 objects.
Deltifying 290305 objects.
 100% (290305/290305) done
fatal: unexpected EOF)      
fatal: packfile '/tmp/wireless-2.6/.git/objects/pack/tmp-DuBFrs' SHA1 mismatch
error: git-fetch-pack: unable to read from git-index-pack
error: git-index-pack died with error code 128
fetch-pack from 'git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git' failed.

I tried several times on two different machines and also (as you can see)
with different git versions.
Could it be a git bug?

-- 
Greetings Michael.
