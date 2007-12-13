From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.25 splat
Date: Wed, 12 Dec 2007 17:39:51 -0800
Message-ID: <20071212173951.4f1eb99a.akpm@linux-foundation.org>
References: <20071212162140.6b81328d.akpm@linux-foundation.org>
	<20071212.162613.186792052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35092 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751089AbXLMBkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 20:40:39 -0500
In-Reply-To: <20071212.162613.186792052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 16:26:13 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 12 Dec 2007 16:21:40 -0800
> 
> > I don't know why it was doing ipv6 things at all.
> 
> When you bring up any interface, with explicit IPV6
> addresses or not, the IPV6 stack seeks out local routers
> and whatnot using multicast and assigns the interface
> a link-local IPV6 address.
> 
> So no matter what you're doing IPV6.
> 
> I suspect the OOPS you hit might be related to
> IPSEC stack work done recently by Herbert Xu who
> has been added to the CC:.
> 
> I doubt poor Ilpo should be contacted as I doubt his
> TCP work is involved :-)

Here's the screen-shot (actually more like a reen-hot):
http://userweb.kernel.org/~akpm/pc121694.jpg

I'm awaiting a reoccurrence with the screen in 50-row mode.
