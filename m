From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 19:09:05 -0700 (PDT)
Message-ID: <20080813.190905.31828583.davem@davemloft.net>
References: <adatzdoiklo.fsf@cisco.com>
	<20080813.161237.10205799.davem@davemloft.net>
	<48A389DB.9050002@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rick.jones2@hp.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: tom@opengridcomputing.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A389DB.9050002@opengridcomputing.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Tucker <tom@opengridcomputing.com>
Date: Wed, 13 Aug 2008 20:26:51 -0500

> Is there any chance your could discuss exactly how a stateless adapter 
> can determine if a network segment
> is in-order, next expected, minus productive ack, paws compliant, etc... 
> without TCP state?

If you're getting packets out of order, data placement optimizations
are the least of your concerns.

In fact this is exactly where we want all of the advanced loss
handling algorithms of the Linux TCP stack to get engaged.
