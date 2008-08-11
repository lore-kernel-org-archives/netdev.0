From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:09:18 -0700 (PDT)
Message-ID: <20080811.140918.213422266.davem@davemloft.net>
References: <adavdy9zc2k.fsf@cisco.com>
	<20080809.224725.130946315.davem@davemloft.net>
	<adabpzzzg81.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adabpzzzg81.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 11 Aug 2008 09:09:02 -0700

>  > We turn it off.  If I want to shape or filter one of these iSCSI
>  > connections can we turn it off?
> 
> That seems like a reasonable idea to me -- the standard thing to do when
> a NIC offload conflicts with something else is to turn off the offload
> and fall back to software.

But as Herbert says, we can make LRO such that turning it off
isn't necessary.

Can we shape the iSCSI offload traffic without turning it off?
