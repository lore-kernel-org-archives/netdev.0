From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Thu, 31 Mar 2016 15:50:15 +0800
Message-ID: <20160331075015.GA27716@gondor.apana.org.au>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com>
 <1459329252.2055.1.camel@sipsolutions.net>
 <20160330.123821.328761526754742195.davem@davemloft.net>
 <56FC0445.6010200@candelatech.com>
 <1459410405.4576.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459410405.4576.8.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2016 at 09:46:45AM +0200, Johannes Berg wrote:
>
> In this case, I think perhaps you can just patch your local system with
> the many interfaces connecting to the same AP to add the parameter
> Herbert suggested (.insecure_elasticity = true in sta_rht_params). This
> is, after all, very much a case that "normal" operation doesn't even
> get close to.

I think you should just turn it on everywhere for mac80211.  Chain
length checks simply don't make sense when you allow duplicate
keys in the hash table.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
