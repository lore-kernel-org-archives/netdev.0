From: Jeff Layton <jlayton@redhat.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Tue, 8 Dec 2009 08:03:31 -0500
Message-ID: <20091208080331.3eb5ddfa@tlielax.poochiereds.net>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com>
	<4B1DC794.5020406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496AbZLHNFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 08:05:14 -0500
In-Reply-To: <4B1DC794.5020406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Dec 2009 22:27:16 -0500
Brian Haley <brian.haley@hp.com> wrote:

> Chuck Lever wrote:
> > I recently added some functions to sunrpc.ko that behave like
> > getnameinfo(AI_NUMERICHOST) does in user space.
> > 
> > One of the functions, rpc_ntop6(), sticks a scope ID on the end of link-
> > and site-local IPv6 addresses.  It does not try to map the scope ID to a
> > device name.
> 
> Site-local addresses have been deprecated...
> 

So this means that addresses with those prefixes should be treated like
any other address, right? If so, then I think the rpc_ntop6 shouldn't be
affixing scopeid's to site local addresses.

-- 
Jeff Layton <jlayton@redhat.com>
