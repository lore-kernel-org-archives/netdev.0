From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #2]
Date: Fri, 16 Mar 2007 17:11:41 +0000
Message-ID: <20070316171141.7a4de504@lxorguk.ukuu.org.uk>
References: <20070316153408.3a9a244a@lxorguk.ukuu.org.uk>
	<20070316151305.04cbc352@lxorguk.ukuu.org.uk>
	<20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<25571.1174054993@redhat.com>
	<26525.1174058071@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:40833 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965397AbXCPQIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 12:08:44 -0400
In-Reply-To: <26525.1174058071@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I know what they are; and I don't think that what's available covers it.
> 
> > and use a proper standard socket type.
> 
> Assuming that that list is exhaustive...

SOCK_RDM seems to match perfectly well here. The point isn't to enumerate
everything in the universe the point is to find "works like" parallels
good enough to avoid more special casing.

