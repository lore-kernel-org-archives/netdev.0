From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Thu, 08 May 2014 17:54:23 -0400 (EDT)
Message-ID: <20140508.175423.2045530728114992634.davem@davemloft.net>
References: <CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<20140508142939.201b3e07@nehalam.linuxnetplumber.net>
	<CA+55aFzOHZcw2o6Cq6rSddSBDZvhgzYToBruak9SLCHxx-fA3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, luto@amacapital.net,
	security@kernel.org, vgoyal@redhat.com, serge@hallyn.com,
	ssorce@redhat.com, ebiederm@xmission.com, netdev@vger.kernel.org,
	jorge@dti2.net
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbaEHVyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 17:54:25 -0400
In-Reply-To: <CA+55aFzOHZcw2o6Cq6rSddSBDZvhgzYToBruak9SLCHxx-fA3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 May 2014 14:41:43 -0700

> Annoying. We may have to revert the changes because of the
> regression, even though it sounds like the new semantics would
> actually be preferred for the very application that regresses...

I think we really have to go with the new semantics, personally.
