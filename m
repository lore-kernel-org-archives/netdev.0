From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:51:29 -0700 (PDT)
Message-ID: <20080811.145129.215922169.davem@davemloft.net>
References: <adabpzzzg81.fsf@cisco.com>
	<20080811.140918.213422266.davem@davemloft.net>
	<adaljz3xmfc.fsf@cisco.com>
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
In-Reply-To: <adaljz3xmfc.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 11 Aug 2008 14:37:59 -0700

>  > But as Herbert says, we can make LRO such that turning it off
>  > isn't necessary.
>  > 
>  > Can we shape the iSCSI offload traffic without turning it off?
> 
> Sure... the same way we can ask the HW vendors to keep old headers
> around when aggregating for LRO, we can ask HW vendors for hooks for
> shaping iSCSI traffic.  And the Chelsio TCP speed record seems to show
> that they already have pretty sophisticated queueing/shaping in their
> current HW.

You don't get it, you can't add the entire netfilter and qdisc
stack into the silly firmware.

And we can't fix bugs there either.
