From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [0/6] Allow registration/change name notifications to fail
Date: Thu, 26 Jul 2007 11:37:15 +0100
Message-ID: <20070726113715.6a4b5af9@oldman.hamilton.local>
References: <20070726090725.GA510@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55891 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755030AbXGZKhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 06:37:52 -0400
In-Reply-To: <20070726090725.GA510@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jul 2007 17:07:25 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> This series of patches adds support to let netdev registration
> and change name events to fail.  Failures of the former kind
> prevents the device from registered while the latter attempts
> to roll back the change (which unfortunately can also fail).
> 
> If the failure occurs while a netdev is being registered,
> then the registration as a whole will fail.  If it occurs
> when a protocol is being registered, then that protocol
> will fail to register instead.
> 
> Having this allows us to flag allocations failures in a 
> meaningful way rather than letting the next action that
> requires what is allocated to flag the failure.
> 
> In particular, this allows the reporting of failures to
> allocate the IPv4/IPv6 device objects.
> 
> Cheers,

Thanks for looking at this, are there bugs this fixes so it should
go to stable?
