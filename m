From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel
 data directly [try #2]
Date: Fri, 16 Mar 2007 15:12:57 +0000
Message-ID: <20070316151257.24238f2a@lxorguk.ukuu.org.uk>
References: <20070316133238.GA2173@infradead.org>
	<20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<20070316125016.3740.96837.stgit@warthog.cambridge.redhat.com>
	<25094.1174053465@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38040 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932857AbXCPOJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 10:09:55 -0400
In-Reply-To: <25094.1174053465@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > very odd line split
> 
> It's not really odd.  The "static" and "inline" don't actually add anything to
> the function template.  They're merely scope limiters / optimisation
> controllers, and so make a lot of sense placed on their own line.

As do many things but the goal of the coding style is consistency and
almost all other code doesn't have the static inline wasting an extra
display line.


