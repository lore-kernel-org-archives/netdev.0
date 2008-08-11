From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:37:59 -0700
Message-ID: <adaljz3xmfc.fsf@cisco.com>
References: <adavdy9zc2k.fsf@cisco.com>
	<20080809.224725.130946315.davem@davemloft.net>
	<adabpzzzg81.fsf@cisco.com>
	<20080811.140918.213422266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:21545 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbYHKViF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:38:05 -0400
In-Reply-To: <20080811.140918.213422266.davem@davemloft.net> (David Miller's
	message of "Mon, 11 Aug 2008 14:09:18 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > But as Herbert says, we can make LRO such that turning it off
 > isn't necessary.
 > 
 > Can we shape the iSCSI offload traffic without turning it off?

Sure... the same way we can ask the HW vendors to keep old headers
around when aggregating for LRO, we can ask HW vendors for hooks for
shaping iSCSI traffic.  And the Chelsio TCP speed record seems to show
that they already have pretty sophisticated queueing/shaping in their
current HW.

 - R.
