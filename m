From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Wed, 29 Apr 2009 09:40:41 -0700
Message-ID: <aday6tj1khi.fsf@cisco.com>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
	<20090428.015535.42660210.davem@davemloft.net>
	<alpine.WNT.2.00.0904281648300.5352@jbrandeb-desk1.amr.corp.intel.com>
	<20090428.175446.191949653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:50011 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbZD2Qkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 12:40:42 -0400
In-Reply-To: <20090428.175446.191949653.davem@davemloft.net> (David Miller's
	message of "Tue, 28 Apr 2009 17:54:46 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > ah, you're right, but this features enables our new hardware that can do 
 > > LRO in hardware, and then GRO can work on top of it if necessary.  We 
 > > wanted some way to turn it off and overloaded the LRO flag to do so.

 > That ugly.  And the kernel is going to turn this off on you
 > when the user enables either forwarding or bridging.

No comment on ugliness.  However it seems like a good feature if the
kernel turns off hardware LRO when forwarding/bridging is turned on --
after all, we don't want the hardware munging wire frames in that case,
for exactly the same reasons that we don't want the kernel LRO munging
frames.

 - R.
