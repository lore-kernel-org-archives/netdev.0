From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Sat, 20 Mar 2004 08:05:55 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319210555.GB479@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF0E.3050708@trash.net> <20040318221523.07298f03.davem@redhat.com> <405B1D1A.6050700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <405B1D1A.6050700@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2004 at 05:17:30PM +0100, Patrick McHardy wrote:
> 
> I can't imagine how. Best would be to avoid the xfrm_prot flag
> completely. Maybe we can add a flag to xfrm_state which indicates
> that this is the last xfrm specified in the policy ?

The same state can be terminal in one policy but not another.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
