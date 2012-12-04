From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: implement multicast fast leave
Date: Tue, 4 Dec 2012 15:07:32 +0800
Message-ID: <20121204070732.GA32550@gondor.apana.org.au>
References: <1354545363-11953-1-git-send-email-amwang@redhat.com>
 <20121203075316.0b1da39d@nehalam.linuxnetplumber.net>
 <20121204013838.GA31329@gondor.apana.org.au>
 <1354604692.15167.7.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:36727 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751308Ab2LDHHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 02:07:38 -0500
Content-Disposition: inline
In-Reply-To: <1354604692.15167.7.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 03:04:52PM +0800, Cong Wang wrote:
>
> Per-port sounds better than per-bridge. And I will make it enabled by
> default.

IMHO the default should be off.  Suddenly losing your subscription
because someone else on the same port unsubscribed is a lot more
annoying than getting a few minutes of unwanted multicast data.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
