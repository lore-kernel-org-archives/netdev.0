From: Meelis Roos <mroos@linux.ee>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 14:00:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903181332140.13734@ondatra.tartu-labor>
References: <20090318112937.675BF13A4B0@koiott.tartu-labor>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postkast.cyber.ee ([195.50.202.7]:56428 "EHLO postkast.cyber.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757609AbZCRMIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 08:08:09 -0400
In-Reply-To: <20090318112937.675BF13A4B0@koiott.tartu-labor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Data is represented in a generic way inside the kernel and the
> operations are defined on the generic data representations, meaning
> its possible to use any matching feature (ranges, masks, set lookups
> etc.) with any kind of data. Semantic validation of the operation is
> performed in userspace, the kernel doesn't care as long as the
> operation doesn't potentially harm the kernel.

This sounds like a "script" downloaded to kernel and interpreted during 
each packet match. This toubles me some - doesn't this use more memory 
accesses to achieve the same work that was done in precompiled code 
before?

Have you measured the fastpath performance of kernel matching of real-life 
rulesets, compared to iptables?

-- 
Meelis Roos (mroos@linux.ee)
