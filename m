From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6 v2] bonding: introduce primary_reselect
	option
Date: Fri, 25 Sep 2009 15:25:19 +0200
Message-ID: <20090925132518.GA3657@psychotron.redhat.com>
References: <20090918195358.GB32154@psychotron.redhat.com> <21492.1253838848@death.nxdomain.ibm.com> <20090925034725.60bcd85b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bonding-devel@lists.sourceforge.net,
	nicolas.2p.debian@free.fr
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbZIYNZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 09:25:37 -0400
Content-Disposition: inline
In-Reply-To: <20090925034725.60bcd85b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 25, 2009 at 09:47:25AM CEST, billfink@mindspring.com wrote:
>On Thu, 24 Sep 2009, Jay Vosburgh wrote:
>
>> 
>> From: Jiri Pirko <jpirko@redhat.com>
>> 
>> In some cases there is not desirable to switch back to primary interface when
>> it's link recovers and rather stay with currently active one. We need to avoid
>> packetloss as much as we can in some cases. This is solved by introducing
>> primary_reselect option. Note that enslaved primary slave is set as current
>> active no matter what.
>> 
>> Patch modified by Jay Vosburgh as follows: fixed bug in action
>> after change of option setting via sysfs, revised the documentation
>> update, and bumped the bonding version number.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>> ---
>> 
>> 	Note that this patch depends on the "make ab_arp select active
>> slaves as other modes" patch recently approved, but not yet appearing in
>> net-next-2.6 as I write this.  http://patchwork.ozlabs.org/patch/32684/
>> 
>>  Documentation/networking/bonding.txt |   42 +++++++++++++++++++++-
>>  drivers/net/bonding/bond_main.c      |   66 +++++++++++++++++++++++++++++++---
>>  drivers/net/bonding/bond_main.c.rej  |   18 +++++++++
>>  drivers/net/bonding/bond_sysfs.c     |   53 +++++++++++++++++++++++++++
>>  drivers/net/bonding/bonding.h        |   11 +++++-
>>  5 files changed, 182 insertions(+), 8 deletions(-)
>>  create mode 100644 drivers/net/bonding/bond_main.c.rej
>
>I doubt you intended to include a patch reject file in your patch.

Noticed - I'm about to resend...
>
>						-Bill
