From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 21:05:36 +0800
Message-ID: <20090403130536.GA11137@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <49D5ED11.2000800@redhat.com> <20090403111242.GA10200@gondor.apana.org.au> <49D5F6FC.5090401@redhat.com> <20090403114828.GA10465@gondor.apana.org.au> <49D5F8DA.20400@redhat.com> <20090403115546.GA10575@gondor.apana.org.au> <49D5FACE.3010302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerd Hoffmann <kraxel@redhat.com>, ghaskins@novell.com,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53866 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764686AbZDCNF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 09:05:57 -0400
Content-Disposition: inline
In-Reply-To: <49D5FACE.3010302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2009 at 03:02:22PM +0300, Avi Kivity wrote:
>
> But it flushes the tap device, the packet still has to go through the  
> bridge + real interface?

Which under normal circumstances should occur before netif_rx_ni
returns.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
