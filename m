From: David Miller <davem@davemloft.net>
Subject: Re: crypto: skcipher - Use eseqiv even on UP machines
Date: Fri, 25 Oct 2013 17:57:53 -0400 (EDT)
Message-ID: <20131025.175753.772571249060520641.davem@davemloft.net>
References: <20131024124149.GA10587@gondor.apana.org.au>
	<20131025065049.GB31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20131025065049.GB31491@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Oct 2013 08:50:49 +0200

> On Thu, Oct 24, 2013 at 08:41:49PM +0800, Herbert Xu wrote:
>> Hi:
>>     
>> Previously we would use eseqiv on all async ciphers in all cases,
>> and sync ciphers if we have more than one CPU.  This meant that
>> chainiv is only used in the case of sync ciphers on a UP machine.
>> 
>> As chainiv may aid attackers by making the IV predictable, even
>> though this risk itself is small, the above usage pattern causes
>> it to further leak information about the host.
>> 
>> This patch addresses these issues by using eseqiv even if we're
>> on a UP machine.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> 
> 
> That's fine by me.
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

I'm ok with this too:

Acked-by: David S. Miller <davem@davemloft.net>
