From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 8 Dec 2010 19:31:32 +0200
Message-ID: <1291829492.17102.38.camel@lb-tlvb-vladz>
References: <4C48BD1A.4060409@chelsio.com>
 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
 <1291825443.31064.193.camel@lb-tlvb-vladz>
 <20101208.083921.71108761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"dm@chelsio.com" <dm@chelsio.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1625 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960Ab0LHRbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 12:31:44 -0500
In-Reply-To: <20101208.083921.71108761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I also agree with Dimitris: what we have here is an offload of some
> > Netfilter functionality to HW. Regardless the HW implementation (TCAM or
> > not) if it's allowed to configure more than one rule for the same
> > protocol the ordering of filtering rules is important: for instance if u
> > change the order of applying the rules in the example below the result
> > of the filtering for the traffic with both VLAN 4 and destination port
> > 3000 will be different.
> 
> It's not the same, this whole ordering thing you expect in netfilter
> land is simply not present in these hardware implementations.
> 
> The hardware does a parallel TCAM match lookup, and whatever matches
> is used.

So, u say that in scope of a single protocol all rules create a set
which ordering is a vendor specific and the same configuration of
n-tuple rules may generate different results for the same traffic on
NICs from different vendors? Don't u think it's confusing from the user
point of view? ;)




