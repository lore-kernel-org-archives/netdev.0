From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 06:05:37 +0200
Message-ID: <20150430040535.GH8950@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <20150430003740.GF7025@acer.localdomain>
 <55417F80.4000506@iogearbox.net>
 <20150430014316.GB7956@acer.localdomain>
 <554194E9.5040002@mojatatu.com>
 <20150430032921.GB8950@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49451 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbD3EFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 00:05:41 -0400
Content-Disposition: inline
In-Reply-To: <20150430032921.GB8950@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.04, Patrick McHardy wrote:
> Regarding TC as a whole, I think the problem is shared between userspace
> and the kernel. iproute TC is certainly completely failed, its unusable
> without looking at the kernel and iproute code, it hasn't even made the
> slightest infrastructrual progess in the past 15 years (*(u16)RTN_DATA(bla))?)
> and that is telling for itself. I don't extend that to ip, even though it
> suffers from the same coding problems, but let's be honest, do you really
> expect some magic is going to happen and TC userspace will suddenly become
> usable?
> 
> I don't. And we intend to provide an alternative.

For the sake of completeness - on ingress, this alternativ means simply
ditching TC. On egress, we will provide a nicely integrated way of qdiscs
and classifiers where nftables will obviously respect the qdiscs. On
ingress, there is simply no benefit in doing that at all. Hence Pablo's
patches.
