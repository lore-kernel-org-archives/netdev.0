From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK]: Use tgid instead of pid for nlmsg_pid
Date: Wed, 23 Nov 2005 11:03:37 +1100
Message-ID: <20051123000337.GA17249@gondor.apana.org.au>
References: <20051121213549.GA28187@ms2.inr.ac.ru> <E1EeJxb-0006xG-00@gondolin.me.apana.org.au> <20051122.144334.23915283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030213AbVKWAEF@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051122.144334.23915283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 02:43:34PM -0800, David S. Miller wrote:
> 
> Applied, of course.

Thanks Dave.
 
> It is possible we accidently reintroduced current->pid when
> we redid all of the netlink hashing. :-)

I just checked using git-whatchanged and that line goes back to
2002 :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
