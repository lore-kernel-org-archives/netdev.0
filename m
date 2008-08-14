From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 18:37:55 -0700 (PDT)
Message-ID: <20080813.183755.72334968.davem@davemloft.net>
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

> Can you explain how this "information" somehow doesn't qualify as 
> "state". Doesn't the next expected sequence number at the very least 
> need to be updated? una? etc...?
> 
> Could you also include the "non-state-full" information necessary to do 
> iSCSI header digest validation, data placement, and marker removal? 

It's stateless because the full packet traverses the real networking
stack and thus can be treated like any other packet.

The data placement is a side effect that the networking stack can
completely ignore if it chooses to.
