From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Thu, 01 Nov 2007 14:52:04 -0700 (PDT)
Message-ID: <20071101.145204.15201968.davem@davemloft.net>
References: <472A1F8A.2070708@hp.com>
	<472A2251.4000701@cosmosbay.com>
	<472A264F.8040201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, ak@suse.de, acme@redhat.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753313AbXKAVwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:52:05 -0400
In-Reply-To: <472A264F.8040201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 01 Nov 2007 20:17:35 +0100

> But if it was an issue, the spinlock array used in IP route cache
> would have the same problem and *someone* should already have
> complained...

I'd say that having a few MB less of rwlock cache lines to
touch offsets the issue even if it does exist.
