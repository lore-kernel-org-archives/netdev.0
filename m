From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Wed, 9 Dec 2009 14:57:31 -0500
Message-ID: <9E4B7973-D2C4-438C-9BF6-A35B343F2363@oracle.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com> <4B1DC794.5020406@hp.com> <20091208080331.3eb5ddfa@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:33504 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757331AbZLIT62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 14:58:28 -0500
In-Reply-To: <20091208080331.3eb5ddfa@tlielax.poochiereds.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian-

On Dec 8, 2009, at 8:03 AM, Jeff Layton wrote:

> On Mon, 07 Dec 2009 22:27:16 -0500
> Brian Haley <brian.haley@hp.com> wrote:
>
>> Chuck Lever wrote:
>>> I recently added some functions to sunrpc.ko that behave like
>>> getnameinfo(AI_NUMERICHOST) does in user space.
>>>
>>> One of the functions, rpc_ntop6(), sticks a scope ID on the end of  
>>> link-
>>> and site-local IPv6 addresses.  It does not try to map the scope  
>>> ID to a
>>> device name.
>>
>> Site-local addresses have been deprecated...
>>
>
> So this means that addresses with those prefixes should be treated  
> like
> any other address, right? If so, then I think the rpc_ntop6  
> shouldn't be
> affixing scopeid's to site local addresses.

As a final detail, we're trying to understand what is the correct  
treatment for site-local addresses.  I've looked at RFC 3879.  In late- 
model Linux kernels, is Jeff's interpretation correct, for application  
layer protocols like RPC?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



