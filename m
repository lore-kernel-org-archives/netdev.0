From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Tue, 30 Oct 2007 14:46:27 -0700 (PDT)
Message-ID: <20071030.144627.56281140.davem@davemloft.net>
References: <20071026153416.GA23491@bingen.suse.de>
	<20071030.005758.184980120.davem@davemloft.net>
	<200710302142.05753.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753307AbXJ3Vqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 17:46:42 -0400
In-Reply-To: <200710302142.05753.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 30 Oct 2007 21:42:05 +0100

> I still have my doubts it makes sense to have an own lock for each bucket. It 
> would be probably better to just divide the hash value through a factor
> again and then use that to index a smaller lock only table.

Yes, and that's why we do it this way in the routing cache hashes.
