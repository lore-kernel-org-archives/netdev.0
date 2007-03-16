From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel data directly [try #2]
Date: Fri, 16 Mar 2007 14:19:02 +0000
Message-ID: <25477.1174054742@redhat.com>
References: <20070316151257.24238f2a@lxorguk.ukuu.org.uk>  <20070316133238.GA2173@infradead.org> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125016.3740.96837.stgit@warthog.cambridge.redhat.com> <25094.1174053465@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146AbXCPOTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 10:19:21 -0400
In-Reply-To: <20070316151257.24238f2a@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> As do many things but the goal of the coding style is consistency and
> almost all other code doesn't have the static inline wasting an extra
> display line.

Actually it doesn't waste an extra display line.  Either the static inline is
on a line of its own, or the first argument is on a line of its own.  Either
way it uses up two lines - unless you want to split it up further and have
four lines as per Christoph's second suggestion (static inline / void /
funcname / 1st arg).

David
