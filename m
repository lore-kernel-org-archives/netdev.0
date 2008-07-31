From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 09:55:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807310942130.4551@wrl-59.cs.helsinki.fi>
References: <20080731004123.GB22826@xi.wantstofly.org>
 <E1KONuu-00017h-00@gondolin.me.apana.org.au> <20080731023652.GA23814@xi.wantstofly.org>
 <20080731030339.GA4327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, akarkare@marvell.com,
	nico@cam.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59103 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbYGaG4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 02:56:00 -0400
In-Reply-To: <20080731030339.GA4327@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2008, Herbert Xu wrote:

> On Thu, Jul 31, 2008 at 04:36:52AM +0200, Lennert Buytenhek wrote:
> >
> > The maximum that splice will allow -- PIPE_BUFFERS * PAGE_SIZE.
> > 
> > I.e. the writes should be large enough.
> 
> Have you looked at the packet dump?

...That would be helpful indeed.

> Maybe it was being constrained by the receiver/congestion windows.

The thing that came into my mind is that the link might still be fast 
enough to make the transfer application limited, can you try setting 
/proc/sys/net/ipv4/tcp_slow_start_after_idle to zero and retest.

-- 
 i.
