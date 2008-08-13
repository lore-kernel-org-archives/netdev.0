From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 13:23:19 -0700 (PDT)
Message-ID: <20080813.132319.175666454.davem@davemloft.net>
References: <20080812.150246.42068558.davem@davemloft.net>
	<200808121521.10101.divy@chelsio.com>
	<48A32976.7060504@vlnb.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, swise@opengridcomputing.com, kxie@chelsio.com,
	netdev@vger.kernel.org, michaelc@cs.wisc.edu, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, dm@chelsio.com,
	leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vst@vlnb.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A32976.7060504@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vladislav Bolkhovitin <vst@vlnb.net>
Date: Wed, 13 Aug 2008 22:35:34 +0400

> This is because the target sends data in a zero-copy manner, so its
> CPU is capable to deal with the load, but on the initiator there are
> additional data copies from skb's to page cache and from page cache
> to application.

If you've actually been reading at all what I've been saying in this
thread you'll see that I've described a method to do this copy
avoidance in a completely stateless manner.

You don't need to implement a TCP stack in the card in order to do
data placement optimizations.  They can be done completely stateless.

Also, large portions of the cpu overhead are transactional costs,
which are significantly reduced by existing technologies such as
LRO.
