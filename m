From: David Howells <dhowells@redhat.com>
Subject: Re: Getting a NIC's MTU size
Date: Thu, 20 Feb 2014 17:30:23 +0000
Message-ID: <16869.1392917423@warthog.procyon.org.uk>
References: <20140217.002153.1121569813590047048.davem@davemloft.net> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk> <27696.1392392957@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbaBTSHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 13:07:34 -0500
In-Reply-To: <20140217.002153.1121569813590047048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> > One further question: If I want to get the MTU size of the NIC through
> > which packets will go to get to a particular peer, can I do:
> 
> As has been suggested or at least hinted to by others, you have to use
> the route dst's device pointer.

So I gather.  My query was intended to be about the safety of accessing the
dst->dev pointer.  Can I just dereference it?  Or do I need to take a lock or
use RCU?

David
