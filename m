From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] IPVS: Modify the SH scheduler to use weights
Date: Wed, 7 Dec 2011 15:20:57 +0900
Message-ID: <20111207062057.GB5813@verge.net.au>
References: <1322604142-15514-1-git-send-email-mike@okcupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
To: Michael Maxim <mike@okcupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37870 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab1LGGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 01:21:01 -0500
Content-Disposition: inline
In-Reply-To: <1322604142-15514-1-git-send-email-mike@okcupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 05:02:22PM -0500, Michael Maxim wrote:
> Modify the algorithm to build the source hashing hash table to add
> extra slots for destinations with higher weight. This has the effect
> of allowing an IPVS SH user to give more connections to hosts that
> have been configured to have a higher weight.

Thanks, applied.
