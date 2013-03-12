From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: Ensure that location of timestamp option is
 stored
Date: Tue, 12 Mar 2013 05:37:26 -0400 (EDT)
Message-ID: <20130312.053726.1354607703288685759.davem@davemloft.net>
References: <1363034619-5887-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780Ab3CLJhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:37:14 -0400
In-Reply-To: <1363034619-5887-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Mon, 11 Mar 2013 16:43:39 -0400

> This is needed in order to detect if the timestamp option appears
> more than once in a packet, to remove the option if the packet is
> fragmented, etc. My previous change neglected to store the option
> location when the router addresses were prespecified and Pointer >
> Length. But now the option location is also stored when Flag is an
> unrecognized value, to ensure these option handling behaviors are
> still performed.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied.
