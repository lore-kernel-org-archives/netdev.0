From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 07/15] rxrpc: Fix accidental cancellation of scheduled resend by ACK parser
Date: Fri, 23 Sep 2016 19:20:31 +0100
Message-ID: <5989.1474654831@warthog.procyon.org.uk>
References: <c868ca22-fed0-67f7-7471-165b3e5a9edd@cogentembedded.com> <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk> <147464376586.5090.14901936645927156006.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59000 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1035173AbcIWSUe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 14:20:34 -0400
In-Reply-To: <c868ca22-fed0-67f7-7471-165b3e5a9edd@cogentembedded.com>
Content-ID: <5988.1474654831.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> >  		case RXRPC_ACK_TYPE_NACK:
> >  			if (anno_type == RXRPC_TX_ANNO_NAK)
> >  				continue;
> > +			if (anno_type == RXRPC_TX_ANNO_RETRANS)
> > +				continue;
> 
>    Why not fold the above 2 *if*s together? Or use *else if* at least?

I have a pending patch that adds something between them.

David
