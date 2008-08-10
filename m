From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sun, 10 Aug 2008 14:24:27 +0800
Message-ID: <E1KS4Lr-0000ts-00@gondolin.me.apana.org.au>
References: <adazlnlzc60.fsf@cisco.com>
Cc: jgarzik@pobox.com, swise@opengridcomputing.com,
	davem@davemloft.net, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: rdreier@cisco.com (Roland Dreier)
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adazlnlzc60.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> wrote:
>
> I think there are two ways to proceed:
> 
> - Start trying to figure out the best way to support the iSCSI offload
>   hardware that's out there.  I don't know the perfect answer but I'm
>   sure we can figure something out if we make an honest effort.
> 
> - Ignore the issue and let users of iSCSI offload hardware (and iWARP
>   and NFS/RDMA etc) stick to hacky out-of-tree solutions.  This pays
>   off if stuff like the Intel CRC32C instruction plus faster CPUs (or
>   "multithreaded" NICs that use multicore better) makes offload
>   irrelevant.  However this ignores the fundamental 3X memory bandwidth
>   cost of not doing direct placement in the NIC, and risks us being in
>   a "well Solaris has support" situation down the road.

We've been here many times before.  This is just the smae old TOE
debate all over again.  The fact with TOE is that history has shown
that Dave's decision has been spot on.

So you're going to have to come up with some really convincing
evidence that shows we are all wrong and these TOE-like hardware
offload solutions is the only way to go.  You can start by collecting
solid benchmark numbers that we can all reproduce and look into.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
