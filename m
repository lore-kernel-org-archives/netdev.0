From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Sat, 23 Aug 2008 01:28:30 -0700 (PDT)
Message-ID: <20080823.012830.262443664.davem@davemloft.net>
References: <200808221840.m7MIeuvB004442@localhost.localdomain>
	<20080822124844.b05ee3e8.akpm@linux-foundation.org>
	<46A00B48CC54E4468EF6911F877AC4CA018D73BB@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: Shyam_Iyer@Dell.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <46A00B48CC54E4468EF6911F877AC4CA018D73BB@blrx3m10.blr.amer.dell.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <Shyam_Iyer@Dell.com>
Date: Sat, 23 Aug 2008 13:52:26 +0530

> >I'd suggest that the version number just be removed.  It becomes
> meaningless (and often misleading) once a driver is in the mainline
> kernel.  People will >update the driver without changing the version
> number.  Code external to the driver but which affects it can change.

I totally disagree.  I find it very useful when I get a debugging
dump from the user and they have no idea where their kernel
came from nor can figure out how to determine the kernel version.

Sure it might sometimes not get updated for trivial patches that
bypass the maintainer, but the maintainer is always going to bump it
after non-trivial changes.
