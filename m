From: Joe Perches <joe@perches.com>
Subject: Re: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 10:37:38 -0800
Message-ID: <1201199858.16268.46.camel@localhost>
References: <20080124122621.3248c651.dada1@cosmosbay.com>
	 <1201195057.16268.32.camel@localhost>  <4798D7B9.5090406@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2100 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbYAXSi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 13:38:28 -0500
In-Reply-To: <4798D7B9.5090406@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-24 at 19:23 +0100, Eric Dumazet wrote:
> Having const data is nice because moving them from .data to .rodata,
> but what would be practical gains to use a const pointer ???

const data is good, using pointers to const data is good.
using const pointers to const data is good.
using const pointers to data not specified as const is not so good.

Here's what you are doing now.

+static void xfrm_put_type(const struct xfrm_type *type)
[...]
+	const struct xfrm_type *type;

cheers, Joe

