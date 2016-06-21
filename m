From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: fix uninitialized variable use
Date: Tue, 21 Jun 2016 11:05:53 +0100
Message-ID: <9370.1466503553@warthog.procyon.org.uk>
References: <6563611.x9M4D6kWiH@wuerfel> <20160617095555.1696781-1-arnd@arndb.de> <3356.1466498932@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbcFUKGo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 06:06:44 -0400
In-Reply-To: <6563611.x9M4D6kWiH@wuerfel>
Content-ID: <9369.1466503553.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:

> > I'm actually more tempted to put a BUG() in there because if any new family
> > support (say AF_INET6) is added, I want to make sure I catch all the places.
> 
> Makes sense. Do you want to do the patch yourself, or should I send
> a new one doing that?
> 
> Maybe WARN() would be better than BUG()? That would still get the attention
> it needs but not kill the process.

I can stick a WARN() into your patch.

David
