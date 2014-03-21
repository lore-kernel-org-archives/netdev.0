From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Thu, 20 Mar 2014 18:56:59 -0700
Message-ID: <87a9cknwk4.fsf@tassilo.jf.intel.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8095 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759983AbaCUB5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 21:57:00 -0400
In-Reply-To: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Thu, 20 Mar 2014 11:49:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> is insane...


Couldn't it just be the cache miss?

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only
