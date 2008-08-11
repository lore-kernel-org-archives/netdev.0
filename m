From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:12:54 -0700 (PDT)
Message-ID: <20080811.141254.165409473.davem@davemloft.net>
References: <adazlnlzc60.fsf@cisco.com>
	<20080809.224637.69833549.davem@davemloft.net>
	<48A08145.6060703@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, jgarzik@pobox.com, swise@opengridcomputing.com,
	divy@chelsio.com, kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A08145.6060703@hp.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 11 Aug 2008 11:13:25 -0700

> David Miller wrote:
> > And I even wonder, these days, if you probably get %90 or more of the
> > gain these "optimized" iSCSI connections obtain from things like LRO.
> > And since LRO can be done entirely in software (although stateless
> > HW assistence helps), it is even a NIC agnostic performance improvement.
> 
> Probably depends on whether or not the iSCSI offload solutions are doing 
> zero-copy receive into the filecache?

That's a data placement issue, which also can be solved with
stateless offloading.
