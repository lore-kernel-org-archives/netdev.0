From: Paul Moore <paul.moore@hp.com>
Subject: Re: + security-selinux-include-netlabelh-fix-two-build-errors.patch added to -mm tree
Date: Fri, 5 Sep 2008 13:02:34 -0400
Message-ID: <200809051302.34768.paul.moore@hp.com>
References: <200809050326.m853QB13012853@imap1.linux-foundation.org> <20080904210033.20700500.randy.dunlap@oracle.com> <200809051244.15420.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:6862 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbYIERCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 13:02:38 -0400
In-Reply-To: <200809051244.15420.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 September 2008 12:44:15 pm Paul Moore wrote:
> On Friday 05 September 2008 12:00:33 am Randy Dunlap wrote:
> > Even with this patch, net/netlabel/netlabel_mgmt.c has build errors
> > when CONFIG_IPV6=n:
>
> Interesting, I tried to reproduce this quickly by changing my
> .config, running 'make oldconfig', verifying that CONFIG_IPV6 was
> still "n" (it was actually commented out), and then running 'make
> M=net/netlabel' ... the result was no error.
>
> You are correct, I obviously made a mistake in the code (which I am
> fixing now) but I don't understand why the steps I took above didn't
> highlight the problem?  What am I missing?

Hmmm, nevermind, the problem seems to have disappeared after 
running 'make prepare scripts'.

> > linux-next-20080904/net/netlabel/netlabel_domainhash.c:79: warning:
> > unused variable 'tmp6'
> > linux-next-20080904/net/netlabel/netlabel_domainhash.c:78: warning:
> > unused variable 'iter6'
> > linux-next-20080904/net/netlabel/netlabel_domainhash.c:340:
> > warning: unused variable 'tmp6'
> > linux-next-20080904/net/netlabel/netlabel_domainhash.c:301:
> > warning: unused variable 'iter6'
> > linux-next-20080904/net/netlabel/netlabel_mgmt.c:219: error:
> > implicit declaration of function 'netlbl_af6list_add'
> > linux-next-20080904/net/netlabel/netlabel_mgmt.c:317: error:
> > implicit declaration of function 'netlbl_af6list_foreach_rcu'
> > linux-next-20080904/net/netlabel/netlabel_mgmt.c:318: error:
> > expected ';' before '{' token make[3]: ***
> > [net/netlabel/netlabel_mgmt.o] Error 1

-- 
paul moore
linux @ hp
