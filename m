From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 v2] bonding: introduce primary_reselect option
Date: Fri, 25 Sep 2009 07:32:46 -0700
Message-ID: <5799.1253889166@death.nxdomain.ibm.com>
References: <20090918195358.GB32154@psychotron.redhat.com> <21492.1253838848@death.nxdomain.ibm.com> <20090925034725.60bcd85b.billfink@mindspring.com> <20090925132518.GA3657@psychotron.redhat.com>
Cc: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:39055 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbZIYOcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 10:32:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8PEVtpN011785
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2009 10:31:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8PEWpxq252638
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2009 10:32:51 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8PETZNk018332
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2009 10:29:36 -0400
In-reply-to: <20090925132518.GA3657@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Fri, Sep 25, 2009 at 09:47:25AM CEST, billfink@mindspring.com wrote:
>>On Thu, 24 Sep 2009, Jay Vosburgh wrote:
>>
>>> 
>>> From: Jiri Pirko <jpirko@redhat.com>
>>> 
>>> In some cases there is not desirable to switch back to primary interface when
>>> it's link recovers and rather stay with currently active one. We need to avoid
>>> packetloss as much as we can in some cases. This is solved by introducing
>>> primary_reselect option. Note that enslaved primary slave is set as current
>>> active no matter what.
>>> 
>>> Patch modified by Jay Vosburgh as follows: fixed bug in action
>>> after change of option setting via sysfs, revised the documentation
>>> update, and bumped the bonding version number.
>>> 
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>>> ---
>>> 
>>> 	Note that this patch depends on the "make ab_arp select active
>>> slaves as other modes" patch recently approved, but not yet appearing in
>>> net-next-2.6 as I write this.  http://patchwork.ozlabs.org/patch/32684/
>>> 
>>>  Documentation/networking/bonding.txt |   42 +++++++++++++++++++++-
>>>  drivers/net/bonding/bond_main.c      |   66 +++++++++++++++++++++++++++++++---
>>>  drivers/net/bonding/bond_main.c.rej  |   18 +++++++++
>>>  drivers/net/bonding/bond_sysfs.c     |   53 +++++++++++++++++++++++++++
>>>  drivers/net/bonding/bonding.h        |   11 +++++-
>>>  5 files changed, 182 insertions(+), 8 deletions(-)
>>>  create mode 100644 drivers/net/bonding/bond_main.c.rej
>>
>>I doubt you intended to include a patch reject file in your patch.
>
>Noticed - I'm about to resend...

	Thanks, guys.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
