From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #2]
Date: Fri, 16 Mar 2007 15:13:05 +0000
Message-ID: <20070316151305.04cbc352@lxorguk.ukuu.org.uk>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38042 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933257AbXCPOKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 10:10:10 -0400
In-Reply-To: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Sockets of AF_RXRPC family are:
> 
>  (1) created as type SOCK_RPC;

There is no such socket type and please don't invent one

If your messages are datagrams and unreliable -> SOCK_DGRAM
If your messages are datagrams and reliable -> SOCK_RDM
If your messages are datagrams, reliable and ordered -> SOCK_SEQPACKET
If your messages are streams of bits, reliable and ordered -> SOCK_STREAM


