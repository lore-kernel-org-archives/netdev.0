From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 12:16:49 +0100
Message-ID: <20050204111649.GB32678@suse.de>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com> <20050203203010.GA7081@gondor.apana.org.au> <20050203141901.5ce04c92.davem@davemloft.net> <20050203235044.GA8422@gondor.apana.org.au> <20050203164922.2627a112.davem@davemloft.net> <20050204012053.GA8949@gondor.apana.org.au> <20050203172357.670c3402.davem@davemloft.net> <20050204015539.GA9727@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, anton@samba.org,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050204015539.GA9727@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 12:55:39PM +1100, Herbert Xu wrote:
> OK, here is the patch to do that.  Let's get rid of kfree_skb_fast
> while we're at it since it's no longer used.

Thanks, I'll give that to the PPC folks and ask the to run with it.

Regards,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
