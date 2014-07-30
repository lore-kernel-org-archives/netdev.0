From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] GSO: Questions for IPVS and GSO for IPv6
Date: Thu, 31 Jul 2014 00:39:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407310034030.1826@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg> <53D86359.2000604@fb.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	kernel-team <Kernel-team@fb.com>
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34190 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752085AbaG3Vjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 17:39:52 -0400
In-Reply-To: <53D86359.2000604@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 29 Jul 2014, Alex Gartrell wrote:

> > +	skb_clear_hash(skb);
> 
> We need this in ipv4 but not in ipv6?

	I got it from iptunnel_xmit(), I don't see it
for IPv6 and I was not very sure about it. We can also
leave it for another patch.

> It sounds like this is going to take a fair amount of work.  Can we set
> gso_type_mask to 0 with a scary comment and push it as a fix and then do the
> right thing as a feature for a future release?

	Yes, 0 or SIT with some comment can be enough
for a bugfix change.

Regards

--
Julian Anastasov <ja@ssi.bg>
