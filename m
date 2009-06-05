From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 14:12:35 -0700
Message-ID: <adafxeev0zg.fsf@cisco.com>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	<20090603.224104.222901210.davem@davemloft.net>
	<alpine.DEB.1.10.0906041150590.3204@gentwo.org>
	<20090604.153057.178458221.davem@davemloft.net>
	<alpine.DEB.1.10.0906050959380.23895@gentwo.org>
	<adaeitywrfj.fsf@cisco.com>
	<alpine.DEB.1.10.0906051444360.29918@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:49431 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbZFEVMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 17:12:34 -0400
In-Reply-To: <alpine.DEB.1.10.0906051444360.29918@gentwo.org> (Christoph
	Lameter's message of "Fri, 5 Jun 2009 15:17:26 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > Yes -- and the required IB multicast resolution seems like it is an L2
 > > thing precisely analogous to ARP.  So I think the original IPoIB code
 > > actually was doing the right thing.
 > 
 > Then why dont the 1G NICs do the same?

ethernet is a different L2 -- you don't have to resolve an IP multicast
address to an L2 address the way you do for IPoIB.

My point is just that multicast group join is the same sort of L2
resolution as ARP is for ethernet, and so having the same sort of
behavior makes sense.

 - R.
