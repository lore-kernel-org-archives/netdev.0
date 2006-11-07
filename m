From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't use highmem in tcp hash size calculation
Date: Mon, 06 Nov 2006 23:12:43 -0800 (PST)
Message-ID: <20061106.231243.99201313.davem@davemloft.net>
References: <454FDC25.6090801@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11159
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754076AbWKGHMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 02:12:39 -0500
To: jheffner@psc.edu
In-Reply-To: <454FDC25.6090801@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Thanks very much for catching this John, patch applied.

Guess what?  Nobody uses HASH_HIGHMEM after this change, and
frankly I can't think of any valid use of it besides perhaps
something such as a page cache hash table but that's irrelevant
since we use a per-object tree data structure for that these
days.

We should probably kill off HASH_HIGHMEM.
