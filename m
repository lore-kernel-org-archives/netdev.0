From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic constants.
Date: Thu, 12 May 2011 07:28:19 +0200
Message-ID: <201105120728.19993.hans.schillstrom@ericsson.com>
References: <20110509.223118.260083861.davem@davemloft.net> <20110510.153051.71135029.davem@davemloft.net> <alpine.LFD.2.00.1105120212150.2431@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:43804 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab1ELF2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 01:28:24 -0400
In-Reply-To: <alpine.LFD.2.00.1105120212150.2431@ja.ssi.bg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 May 2011 01:32:09 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 10 May 2011, David Miller wrote:
> 
> > > 	Following patch can be used after patch 4, eg. as
> > > number 6 because patches 4 and 5 are ok and we are going to replace
> > > patches 6 and 7.
> > 
> > Thanks Julian.
> > 
> > What I'm going to do is hold back the IPVS parts of the patches I
> > posted last night.  In particular, I'll integrate this into the
> > original patch #4.
> > 
> > And then we can work through the reimplementation ideas you posted to
> > me in private email.
> 
> 	My simple tests do not show any problems with patches
> 4, 5 and the new 6 and 7. I tested TUN mode for rt_src/rt_dst
> and DR/NAT for rt_dst replacement, related ICMP is relayed properly.
> So, we should be ok but I'll do more tests in the following
> days because the list with possible combinations for testing
> is too long: different forwarding mode (DR/TUN/NAT),
> local or remote real server, local or remote client,
> In or Out related ICMP, Passive or Active FTP...
> 
I will try to test the Backup/Failover aspects of above

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
