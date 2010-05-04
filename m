From: Brian Haley <brian.haley@hp.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 03 May 2010 22:16:39 -0400
Message-ID: <4BDF8387.4000303@hp.com>
References: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:9736 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0EDCQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 22:16:42 -0400
In-Reply-To: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enh wrote:
> RFC 3493 (http://tools.ietf.org/rfc/rfc3493.txt) says:
> 
>       IPV6_MULTICAST_HOPS
> 
>          Set the hop limit to use for outgoing multicast packets.  (Note
>          a separate option - IPV6_UNICAST_HOPS - is provided to set the
>          hop limit to use for outgoing unicast packets.)
> 
>          The interpretation of the argument is the same as for the
>          IPV6_UNICAST_HOPS option:
> 
>             x < -1:        return an error of EINVAL
>             x == -1:       use kernel default
>             0 <= x <= 255: use x
>             x >= 256:      return an error of EINVAL
> 
>             If IPV6_MULTICAST_HOPS is not set, the default is 1
>             (same as IPv4 today)
> 
>          Argument type: int
> 
> but if i create a socket and call getsockopt, i get 64, not 1. this
> happens both on Android (2.6.32) and on Ubuntu 8.04 (2.6.24).

<snip>

> is this a bug? is this the right place to report it? thanks!

It looks like a bug to me, feel free to send along a patch :)

-Brian

