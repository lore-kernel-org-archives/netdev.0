From: Andi Kleen <andi@firstfloor.org>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in arp_packet_match()
Date: Wed, 25 Mar 2009 11:33:32 +0100
Message-ID: <878wmt6geb.fsf@basil.nowhere.org>
References: <20090324.132954.148903398.davem@davemloft.net>
	<49C94B6A.5020304@cosmosbay.com>
	<alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr>
	<20090324.141848.119353425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jengelh@medozas.de, dada1@cosmosbay.com, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45355 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbZCYKdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 06:33:40 -0400
In-Reply-To: <20090324.141848.119353425.davem@davemloft.net> (David Miller's message of "Tue, 24 Mar 2009 14:18:48 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> memcmp() can't make any assumptions about alignment.

Newer gcc often[1] knows how to generate specialized aligned memcmp()
based on the type alignment.

However you need to make sure the input types are right.

So in theories some casts might be enough given a new enough
compiler.

[1] not always unfortunately, sometimes it loses this information.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
