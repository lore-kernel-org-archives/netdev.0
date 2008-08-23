From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Sat, 23 Aug 2008 14:37:53 +0530
Message-ID: <46A00B48CC54E4468EF6911F877AC4CA018D73BC@blrx3m10.blr.amer.dell.com>
References: <200808221840.m7MIeuvB004442@localhost.localdomain><20080822124844.b05ee3e8.akpm@linux-foundation.org><46A00B48CC54E4468EF6911F877AC4CA018D73BB@blrx3m10.blr.amer.dell.com> <20080823.012830.262443664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <akpm@linux-foundation.org>, <kxie@chelsio.com>,
	<netdev@vger.kernel.org>, <open-iscsi@googlegroups.com>,
	<linux-scsi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <michaelc@cs.wisc.edu>,
	<swise@opengridcomputing.com>, <rdreier@cisco.com>,
	<daisyc@us.ibm.com>, <wenxiong@us.ibm.com>, <bhua@us.ibm.com>,
	<divy@chelsio.com>, <dm@chelsio.com>, <leedom@chelsio.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:63224 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYHWJI4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 05:08:56 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080823.012830.262443664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> David Miller wrote: 
> > Andrew Morton wrote:
> >I'd suggest that the version number just be removed.  It becomes
> meaningless (and often misleading) once a driver is in the mainline 
> kernel.  People will >update the driver without changing the version 
> number.  Code external to the driver but which affects it can change.

>I totally disagree.  I find it very useful when I get a debugging dump
from the user and they have no idea where their kernel came from nor can
figure 
>out how to determine the kernel version.

>Sure it might sometimes not get updated for trivial patches that bypass
the maintainer, but the maintainer is always going to bump it after
non-trivial 
>changes.

Exactly. And I am also suggesting that the driver version is not
standard among different vendors. So, why not get them generated in an
automatic build process.
Something like "kernel-version.driver-version". I am just imagining
here. The details can be worked out.

-Shyam
