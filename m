From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Wed, 09 Dec 2009 17:50:09 -0500
Message-ID: <4B2029A1.5010404@hp.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com> <4B1DC794.5020406@hp.com> <20091208080331.3eb5ddfa@tlielax.poochiereds.net> <9E4B7973-D2C4-438C-9BF6-A35B343F2363@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:15449 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758541AbZLIWuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 17:50:37 -0500
In-Reply-To: <9E4B7973-D2C4-438C-9BF6-A35B343F2363@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chuck,

Chuck Lever wrote:
>> So this means that addresses with those prefixes should be treated like
>> any other address, right? If so, then I think the rpc_ntop6 shouldn't be
>> affixing scopeid's to site local addresses.
> 
> As a final detail, we're trying to understand what is the correct
> treatment for site-local addresses.  I've looked at RFC 3879.  In
> late-model Linux kernels, is Jeff's interpretation correct, for
> application layer protocols like RPC?

Not sure if this answers the question, but recent Linux kernels only look
at the scope ID for link-local addresses.

-Brian
