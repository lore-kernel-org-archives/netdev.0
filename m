From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:53:13 -0700 (PDT)
Message-ID: <20080811.145313.178992274.davem@davemloft.net>
References: <48A08145.6060703@hp.com>
	<20080811.141254.165409473.davem@davemloft.net>
	<adad4kfxm9v.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, jgarzik@pobox.com, swise@opengridcomputing.com,
	divy@chelsio.com, kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adad4kfxm9v.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 11 Aug 2008 14:41:16 -0700

>  > > Probably depends on whether or not the iSCSI offload solutions are doing 
>  > > zero-copy receive into the filecache?
>  > 
>  > That's a data placement issue, which also can be solved with
>  > stateless offloading.
> 
> How can you place iSCSI data properly with only stateless offloads?

By teaching the stateless offload how to parse the iSCSI headers
on the flow and place the data into pages at the correct offsets
such that you can place the pages hanging off of the SKB directly
into the page cache.
