From: Brian Haley <brian.haley@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 12:00:11 -0400
Message-ID: <49BFC90B.8000206@hp.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <49BF0F4D.7000409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Felix von Leitner <felix-kernel@fefe.de>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:12823 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbZCQQAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 12:00:16 -0400
In-Reply-To: <49BF0F4D.7000409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> To me, section 3.7 of RFC 3493 is not gray. It is only refering to interoperate
> with IPV4 applications. 
> Ie *sending* UDP messages to IPV4 nodes, or *connect* to TCP IPV4 nodes.
> 
> So "::ffff:0.0.0.0" has no meaning to contact an IPV4 node, since 0.0.0.0 is not
> a valid IPV4 address.

I agree with you Eric :)  I was simply referring to the fact that RFC 3493
doesn't distinguish between valid and invalid use of mapped addresses:

  IPv4-mapped addresses are written as follows:

      ::FFFF:<IPv4-address>

<IPv4-address> could be interpreted as 0.0.0.0 if you take that little section
out of context.

-Brian
