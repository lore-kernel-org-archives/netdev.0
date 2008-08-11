From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 09:09:02 -0700
Message-ID: <adabpzzzg81.fsf@cisco.com>
References: <489CC58D.4010606@pobox.com>
	<20080809.002840.167363463.davem@davemloft.net>
	<adavdy9zc2k.fsf@cisco.com>
	<20080809.224725.130946315.davem@davemloft.net>
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
Received: from sj-iport-6.cisco.com ([171.71.176.117]:47626 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbYHKQJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 12:09:40 -0400
In-Reply-To: <20080809.224725.130946315.davem@davemloft.net> (David Miller's
	message of "Sat, 09 Aug 2008 22:47:25 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > We turn it off.  If I want to shape or filter one of these iSCSI
 > connections can we turn it off?

That seems like a reasonable idea to me -- the standard thing to do when
a NIC offload conflicts with something else is to turn off the offload
and fall back to software.

 - R.
