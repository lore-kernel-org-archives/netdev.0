From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [IPV4 0/9] TRIE performance patches
Date: Thu, 24 Jan 2008 10:36:45 +0100
Message-ID: <18328.23597.205001.332244@robur.slu.se>
References: <20080122233733.404145234@linux-foundation.org>
	<18327.18935.137799.285515@robur.slu.se>
	<20080123154933.233c4909@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:58983 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbYAXJgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 04:36:39 -0500
In-Reply-To: <20080123154933.233c4909@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:

 > Dumping by prefix is possible, but unless 32x slower. Dumping in
 > address order is just as logical. Like I said, I'm investigating what
 > quagga handles.

 How about taking a snapshot to in address order (as you did) to some 
 allocated memory, returning from that memory in prefix order? This would 
 solve the  -EBUSY too and give a consistent view of the routing table at
 the time for the dump/snapshot.

 Cheers
					--ro
