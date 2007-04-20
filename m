From: David Miller <davem@davemloft.net>
Subject: Re: Getting the new RxRPC patches upstream
Date: Fri, 20 Apr 2007 01:58:38 -0700 (PDT)
Message-ID: <20070420.015838.83621529.davem@davemloft.net>
References: <29341.1176975158@redhat.com>
	<2969.1176992303@redhat.com>
	<1101.1177056127@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, akpm@osdl.org, containers@lists.osdl.org,
	oleg@tv-sign.ru, hch@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766516AbXDTI6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 04:58:35 -0400
In-Reply-To: <1101.1177056127@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 20 Apr 2007 09:02:07 +0100

> David Miller <davem@davemloft.net> wrote:
> 
> > I applied already the patches I thought were appropriate,
> > you had some crypto layer changes that you need to work
> > out with Herbert Xu before the rest can be applied.
> 
> Should the rest of it go via Andrew's tree then?

Now that Herbert cleared up the crypto layer issues
the only problem left is that there are generic changes
in there which are not strictly networking but which
your subsequent networking changes depend upon.

This is a mess, and makes merging your work into the
net-2.6.22 tree more difficult.

Is it possible for your changes to be purely networking
and not need those changes outside of the networking?

I guess one of them was just a symbol export which I
could add to the net-2.6.22 tree, but weren't there some
more involved non-networking bits in there?
