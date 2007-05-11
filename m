From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 04:16:44 -0700
Message-ID: <adad517zk2r.fsf@cisco.com>
References: <p73wszfenni.fsf@bingen.suse.de>
	<OFAF0AE4C2.388D2428-ON652572D8.002E0FFF-652572D8.002EF597@in.ibm.com>
	<20070511093714.GR2012@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:48999 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbXEKLQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 07:16:54 -0400
In-Reply-To: <20070511093714.GR2012@bingen.suse.de> (Andi Kleen's message of "Fri, 11 May 2007 11:37:14 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I wasn't talking about sending.
 > 
 > But there actually is :- TSO/GSO.

As I said before, getting multiple packets in one call to xmit would
be nice for amortizing per-xmit overhead in IPoIB.  So it would be
nice if the cases where the stack does GSO ended up passing all the
segments into the driver in one go.

 - R.
