From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 20:05:06 +1000
Message-ID: <20110505100506.GA20111@gondor.apana.org.au>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au> <20110504232854.GA11687@rere.qmqm.pl> <20110505084428.GB17647@redhat.com> <4DC26F33.8010700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37902 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab1EEKFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 06:05:17 -0400
Content-Disposition: inline
In-Reply-To: <4DC26F33.8010700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 05:34:43PM +0800, Shan Wei wrote:
>
> TUN_F_TSO4, TUN_F_TSO6, TUN_F_TSO_ECN, TUN_F_UFO these features are 
> depend on NETIF_F_SG. If NETIF_F_SG is not set, these features are not be
> enabled and  warnings are printed in netdev_fix_features().

No, when the user turns off checksum offload everything should
be turned off as well.  However, when it's turned on, we shouldn't
enable everything automatically.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
