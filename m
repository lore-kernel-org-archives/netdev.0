From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Sat, 23 Aug 2008 13:52:26 +0530
Message-ID: <46A00B48CC54E4468EF6911F877AC4CA018D73BB@blrx3m10.blr.amer.dell.com>
References: <200808221840.m7MIeuvB004442@localhost.localdomain> <20080822124844.b05ee3e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <open-iscsi@googlegroups.com>,
	<linux-scsi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <davem@davemloft.net>, <michaelc@cs.wisc.edu>,
	<swise@opengridcomputing.com>, <rdreier@cisco.com>,
	<daisyc@us.ibm.com>, <wenxiong@us.ibm.com>, <bhua@us.ibm.com>,
	<divy@chelsio.com>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<kxie@chelsio.com>
To: <akpm@linux-foundation.org>, <kxie@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080822124844.b05ee3e8.akpm@linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Andrew Morton wrote:
> > + *
> > + * Written by: Karen Xie (kxie@chelsio.com)  */
> > +
> > +#include "cxgb3i.h"
> > +
> > +#define DRV_MODULE_NAME         "cxgb3i"
> > +#define DRV_MODULE_VERSION      "1.0.0"

>I'd suggest that the version number just be removed.  It becomes
meaningless (and often misleading) once a driver is in the mainline
kernel.  People will >update the driver without changing the version
number.  Code external to the driver but which affects it can change.

>The kernel version identifier is really the only way in whcih you and
your support people can reproduce a user's code.

> > +#define DRV_MODULE_RELDATE      "May 1, 2008"

>Ditto.


It gives us a stick to ask vendors to maintain upstream versions of
driver code in the distros. 

While we are at this. I believe that there is not much of a standard for
driver versioning. If we automatically get a driver version from the
kernel version then it solves both problems. Thoughts ??

Thanks,
Shyam
