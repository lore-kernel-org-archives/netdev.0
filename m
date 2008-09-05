From: Paul Moore <paul.moore@hp.com>
Subject: Re: + security-selinux-include-netlabelh-fix-two-build-errors.patch added to -mm tree
Date: Fri, 5 Sep 2008 07:44:24 -0400
Message-ID: <200809050744.25058.paul.moore@hp.com>
References: <200809050326.m853QB13012853@imap1.linux-foundation.org> <20080904210033.20700500.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:22634 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbYIELo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 07:44:29 -0400
In-Reply-To: <20080904210033.20700500.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 September 2008 12:00:33 am Randy Dunlap wrote:
> On Thu, 04 Sep 2008 20:26:11 -0700 akpm@linux-foundation.org wrote:

...

> > security/selinux/include/netlabel.h:74: error: two or more data
> > types in declaration specifiers
> > security/selinux/include/netlabel.h:106: error: expected ';', ','
> > or ')' before 'u32'
> >
> > Caused by
> >
> >     commit b023202e2a41a61165f472cc889f37c4a260ba51
> >     Author: Paul Moore <paul.moore@hp.com>
> >     Date:   Tue Sep 2 10:24:41 2008 -0400
> >
> >         selinux: Fix missing calls to netlbl_skbuff_err()

...

> Even with this patch, net/netlabel/netlabel_mgmt.c has build errors
> when CONFIG_IPV6=n:

Thanks, I'll get these fixed today.

-- 
paul moore
linux @ hp
