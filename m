From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 07:23:52 +0100
Message-ID: <49A4E3F8.4050406@trash.net>
References: <49A4D5D5.5090602@trash.net> <20090225061902.GA32430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52491 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbZBYGXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 01:23:55 -0500
In-Reply-To: <20090225061902.GA32430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Feb 25, 2009 at 06:23:33AM +0100, Patrick McHardy wrote:
>> An easy fix would be to keep track of whether sysctl unregistration
>> is in progress in IPv4/IPv6 and ignore new requests from that point
>> on. Its not very elegant though, so I was wondering whether anyone
>> has a better suggestion.
> 
> We could make the unregistration asynchronous and invoke a callback
> when it's done.  Then we can simply hold a net_device refcount and
> relinquish it in the callback

That sounds simple enough. I'll see if I can come up with a patch, thanks.
