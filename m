From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 17:41:47 +0800
Message-ID: <20090402094147.GA30586@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au> <49D487A6.407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52166 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757546AbZDBJmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:42:03 -0400
Content-Disposition: inline
In-Reply-To: <49D487A6.407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 12:38:46PM +0300, Avi Kivity wrote:
>
> Why does a kernel solution not need to know when a packet is transmitted?

Because you can install your own destructor?

I don't know what Greg did, but netback did that nasty page destructor
hack which Jeremy is trying to undo :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
