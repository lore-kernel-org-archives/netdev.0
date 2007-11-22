From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Thu, 22 Nov 2007 11:46:21 +0900 (JST)
Message-ID: <20071122.114621.02788123.yoshfuji@linux-ipv6.org>
References: <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
	<4744CAA4.50102@garzik.org>
	<20071122023403.GA3409@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36312 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757550AbXKVCqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 21:46:18 -0500
In-Reply-To: <20071122023403.GA3409@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071122023403.GA3409@gondor.apana.org.au> (at Thu, 22 Nov 2007 10:34:03 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Wed, Nov 21, 2007 at 07:17:40PM -0500, Jeff Garzik wrote:
> >
> > For those interested, I am dealing with a UDP app that already does very 
> > strong checksumming and encryption, so additional software checksumming 
> > at the lower layers is quite simply a waste of CPU cycles.  Hardware 
> > checksumming is fine, as long as its "free."
> 
> No matter how strong your underlying checksumming is it's not
> going to protect the IPv6 header is it :)

In that sense, we should use AH.

--yoshfuji
