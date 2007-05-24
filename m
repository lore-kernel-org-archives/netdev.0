From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [IPv6] UDP Encapsulation of IPsec ESP Packets
Date: Thu, 24 May 2007 18:03:30 +0900
Message-ID: <1179997410.20254.29.camel@sebastian.intellilink.co.jp>
References: <E1Hr8mJ-00024X-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.oss.ntt.co.jp ([222.151.198.98]:50449 "EHLO
	serv1.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263AbXEXJDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 05:03:53 -0400
In-Reply-To: <E1Hr8mJ-00024X-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-24 at 18:34 +1000, Herbert Xu wrote:
> Fernando Luis V??zquez Cao <fernando@oss.ntt.co.jp> wrote:
> > I noticed that IPv4-over-IPv6 made into 2.6.21 (thank you!) and that
> > prompted to check the progress with the implementation of rfc3948 (UDP
> > Encapsulation of IPsec ESP Packets) in Linux. For IPv4 the code is
> > already there, but that does not seem to be the case for IPv6. I have
> > checked the usagi kernels and Dave S. Miller's net git tree and could
> > not find anything.
> > 
> > Is anyone working on this? I would appreciate any information on the
> > status of this work.
> 
> If we don't have NAT on IPv6 why would you need UDP encapsulation?
Hi Herbert,

Thank you for your feedback.

Depending on the filtering rules it is possible that a gateway/firewall
does not accept incoming ESP packets. When the filter rules of the
firewall cannot be changed (because one is not the administrator) the
only way of traversing the firewall is using some sort of encapsulation,
such as UDP encapsulation.

Is there any other way to circumvent this issue?

(By the way, the premise is that network is a pure ipv6 environment)

 - Fernando

