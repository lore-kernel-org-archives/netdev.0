From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 19:37:28 +0900 (JST)
Message-ID: <20070209.193728.11390586.yoshfuji@linux-ipv6.org>
References: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>
	<20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
	<7426.1171017094@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org, yoshfuji@linux-ipv6.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54382 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946353AbXBIKha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 05:37:30 -0500
In-Reply-To: <7426.1171017094@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <7426.1171017094@redhat.com> (at Fri, 09 Feb 2007 10:31:34 +0000), David Howells <dhowells@redhat.com> says:

> YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:
> 
> > This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> > Please use sockaddr_storage{} (or sockaddr{}, maybe), and make it
> > sure to align on 64-bit word.
> 
> That won't work.  That would then make the address larger than the maximum
> size (ie: sizeof(struct sockaddr_storage)).

sockaddr{}, then...

--yoshfuji
