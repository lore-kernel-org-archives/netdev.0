From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Tue, 1 Feb 2005 07:26:08 +1100
Message-ID: <20050131202608.GA8794@gondor.apana.org.au>
References: <20050130224404.5f78d28a.akpm@osdl.org> <E1CvZCT-00017g-00@gondolin.me.apana.org.au> <20050131114004.6c61cdc1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, au@unterluggauer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050131114004.6c61cdc1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 31, 2005 at 11:40:04AM -0800, David S. Miller wrote:
> 
> Yes, but the loop in the kernel must be prevented nevertheless,
> buggy userland or not.

I'm not sure that there is a loop.  Apart from the word hang in the
subject line, the submitter didn't talk about a loop at all.

Perhaps he's referring to the loop where the kernel continuously
sends acquire messages to racoon but racoon responds by doing
duplicate adds thus deleting the larval SAs?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
