From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Tue, 22 Nov 2005 11:09:59 +1100
Message-ID: <20051122000959.GA27615@gondor.apana.org.au>
References: <E1EeJwF-0006wc-00@gondolin.me.apana.org.au> <43824F57.1040007@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932484AbVKVAKR@vger.kernel.org>
To: Christopher Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <43824F57.1040007@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2005 at 04:51:03PM -0600, Christopher Friesen wrote:
> 
> Should that be getsockname(2)?  Anyways, I now understand the issues.

Yes that's what I meant.

> As it turns out, we were actually already calling getsockname() a bit 
> earlier in the code path, so we can just use the "pid" value from there.

Excellent.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
