From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for '8139cp-20060912-00' branch
Date: Wed, 13 Sep 2006 09:07:00 +0200
Message-ID: <20060913070700.GA15444@electric-eye.fr.zoreil.com>
References: <20060912192039.GA4482@electric-eye.fr.zoreil.com> <450766D5.1070802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:27874 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751644AbWIMHI7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 03:08:59 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <450766D5.1070802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> :
> Francois Romieu wrote:
> >Please pull from tag '8139cp-20060912-00' in repository
> >
> >git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git
> >
> >to get the change below:
> >
> >(patch applies to jeff#upstream-linus)
> 
> Pulled, but there are some git problems to address...
> 
> * Never use 'upstream-linus' branch.
> 
> * Base off of vanilla Linus linux-2.6.git, unless you are submitting on 
> top of changes that are in netdev#upstream or netdev#upstream-fixes.
> 
> * For some reason, when I pulled, it fetched over 17,000 objects!

I am dazed.

The tag 8139cp-20060912-00 currently references the head of the branch
8139cp.

$ git show master
commit 05ff0e291af086f4325bac76abad250690bbbd63
Merge: 5eea7ee... 55669bf...
Author: Linus Torvalds <torvalds@g5.osdl.org>
Date:   Mon Sep 11 11:43:17 2006 -0700

    Merge branch 'audit.b28' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
    
    * 'audit.b28' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current:
      [PATCH] audit: AUDIT_PERM support
[...]

$ git merge-base 8139cp master
dc709bd190c130b299ac19d596594256265c042a

$ git log --pretty=short $(git merge-base 8139cp master)..8139cp | grep commit
commit 48907e39890590792c58272604cfb34ad1d80054
commit cccb20d3a9b7c6d4b6e1b52ee02814e6094aaa12
commit 7668a4945ba0e17a61e535a6c67aa64a319a03b4
commit e68970e7543815133224f79a858e7c9e0c42f4de
commit d03d376dd29cae53bf70a21a0c26b306abe37326
commit 0ba894d420b845667e2981c2147af974a755fba2
commit c48e9399e895834f26dff9149de1930ba18a0d6c
commit 3598b57be449a2ee9178e5c511bdb1a8aaccba20

Where do the 17000 objects come from ?

-- 
Ueimor
