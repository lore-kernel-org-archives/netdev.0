From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Increase default copybreak limits to 2k
Date: Thu, 21 Oct 2010 07:45:25 -0700 (PDT)
Message-ID: <20101021.074525.71113963.davem@davemloft.net>
References: <20101021143753.GA5567@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43347
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758429Ab0JUOpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:45:02 -0400
In-Reply-To: <20101021143753.GA5567@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jennings <rcj@linux.vnet.ibm.com>
Date: Thu, 21 Oct 2010 09:37:53 -0500

> Increase the copybreak limits for rx and tx from 128 bytes
> to 2048 bytes. These limits were added by commits
> 8d86c61ae41d9068fd5e5cc01a4abd53c4fe3ab5 and
> c08cc3ccebd46dce44d13a8ce81d249e687eeb8a to make use of a
> bounce buffer for packets below 128 bytes.  This avoids
> tearing down and creating a TCE entry.
> 
> Performance testing shows that this default limit can be
> increased from 128 to 2048 for both rx and tx copybreak.
> This resulted in ~10% throughput increase for for packets
> that fit this limit without affecting performance for larger
> packets.
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

For a default MTU of 1500 this means the copybreak will
never be used.

This makes absolutely no sense, are you doing these tests
with Jumbo frames?
