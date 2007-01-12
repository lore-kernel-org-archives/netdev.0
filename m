From: Willy Tarreau <w@1wt.eu>
Subject: Re: [2.4 PATCH] ethernet (net/ethernet/eth.c): eth_header() may produce invalid packets (with dest. addr. = 00:00:00:00:00:00)
Date: Fri, 12 Jan 2007 06:39:30 +0100
Message-ID: <20070112053930.GA9136@1wt.eu>
References: <45A4D3BB.9080304@cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1924 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1160998AbXALFxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 00:53:45 -0500
To: Christian Praehauser <cpraehaus@cosy.sbg.ac.at>,
	davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <45A4D3BB.9080304@cosy.sbg.ac.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 12:53:31PM +0100, Christian Praehauser wrote:
> Hello, and sorry for bothering you with a patch you've already seen ;-).

I had not seen it yet, so I'm fine with it :-)

> From: Christian Praehauser, Department of Computer Sciences, University of 
> Salzburg
> 
> This patch fixes a problem which has already been corrected in Linux-2.6.16 
> but was not back-ported to the 2.4 series. It is essentially the same as 
> the patch for 2.6.16. An excerpt from the ChangeLog for Linux 2.6.16 is 
> included below.

David, I think that Christian and Alexey's descriptions are fine, and that
this patch should be merged. Are you OK ?

> What is not described in the patch description for 2.6.16 is that this 
> problem also arises when transmitting IP multicast packets. If you send an 
> IP multicast stream over an ethernet network interface ethX and turn off 
> ARP on ethX then Linux will produce an ethernet frame with a dest. 
> addresses of 00:00:00:00:00:00 (which is invalid). As IP multicast 
> addresses are directly mapped to HW (MAC) addresses without invoking any 
> ARP protocol mechanisms - for IP4 this mapping is performed by the function 
> ip_eth_mc_map - it makes perfect sense to do this even if ARP is disabled. 
> Further, this problem may occur periodically, everytime the corresponding 
> struct dst_entry is garbage-collected (e.g. ~ every 10 minutes).

Christian, would you please produce a properly formated description starting
from the 2.6 one and appending your comments to it ? I'd also like to get
the same subject as for the 2.6 patch. It's important that we keep patches
subjects and descriptions for backports, it helps further patch tracking.

Thanks in advance,
Willy

