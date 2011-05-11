From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic
 constants.
Date: Thu, 12 May 2011 02:32:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105120212150.2431@ja.ssi.bg>
References: <20110509.223118.260083861.davem@davemloft.net> <alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg> <20110510.153051.71135029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45209 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932641Ab1EKXag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 19:30:36 -0400
In-Reply-To: <20110510.153051.71135029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 10 May 2011, David Miller wrote:

> > 	Following patch can be used after patch 4, eg. as
> > number 6 because patches 4 and 5 are ok and we are going to replace
> > patches 6 and 7.
> 
> Thanks Julian.
> 
> What I'm going to do is hold back the IPVS parts of the patches I
> posted last night.  In particular, I'll integrate this into the
> original patch #4.
> 
> And then we can work through the reimplementation ideas you posted to
> me in private email.

	My simple tests do not show any problems with patches
4, 5 and the new 6 and 7. I tested TUN mode for rt_src/rt_dst
and DR/NAT for rt_dst replacement, related ICMP is relayed properly.
So, we should be ok but I'll do more tests in the following
days because the list with possible combinations for testing
is too long: different forwarding mode (DR/TUN/NAT),
local or remote real server, local or remote client,
In or Out related ICMP, Passive or Active FTP...

Regards

--
Julian Anastasov <ja@ssi.bg>
