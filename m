From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sun, 27 Sep 2015 03:55:48 +0800
Message-ID: <20150926195548.GA19064@gondor.apana.org.au>
References: <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
 <20150926194916.GA18975@gondor.apana.org.au>
 <20150926195245.GF3572@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150926195245.GF3572@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 26, 2015 at 03:52:45PM -0400, Tejun Heo wrote:
> 
> Ah, yeah, you're right.  We need to check that there because it may
> contain a garbage value.  I still think it'd better to use
> netlink_bound() test in connect() too tho.

Well I disagree.  When I say that it returns to user-space I really
mean that the next time we use portid via the same call path that
triggered the connect we must be checking nlk->bound anyway.

Good luck finding more bugs in this code :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
