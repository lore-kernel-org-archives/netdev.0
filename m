From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 13:02:28 +0000
Message-ID: <30372.1457442148@warthog.procyon.org.uk>
References: <29908.1457437197@warthog.procyon.org.uk> <20160307.230737.1738396720590983620.davem@davemloft.net> <20160307143759.18567.8234.stgit@warthog.procyon.org.uk> <20160307143806.18567.30020.stgit@warthog.procyon.org.uk> <23389.1457390714@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, David Miller <davem@davemloft.net>,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbcCHNCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 08:02:31 -0500
In-Reply-To: <29908.1457437197@warthog.procyon.org.uk>
Content-ID: <30371.1457442148.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> Does it make sense to maintain a FIFO list of connections (though this would
> mean potentially taking a spinlock every time I get a packet)?

It occurs to me that only inactive connections would need to be on an LRU
list.  Any connection with packets or active calls to deal with wouldn't be on
the list.

David
