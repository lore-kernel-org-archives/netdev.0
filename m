From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Wed, 11 May 2005 08:07:51 +1000
Message-ID: <20050510220751.GA459@gondor.apana.org.au>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Content-Disposition: inline
In-Reply-To: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2005 at 12:43:32PM +0000, Ken-ichirou MATSUZAWA wrote:
> 
> Everytime on shutting down, the subject message is logged.  
> It seems that the reason is do_one_broadcast may preempt
> netlink_recvmsg. Added patch to 2.6.12-rc4 seems resolving this
> problem.

Thanks for the patch.  To help me understand the problem better,
could you please tell me:

1) Is this reproducible under 2.6.12-rc4 without your patch?
2) What application is holding the netlink socket?
3) Is your machine SMP, PREEMPT, or both?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
