From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK]: Use tgid instead of pid for nlmsg_pid
Date: Tue, 22 Nov 2005 14:43:34 -0800 (PST)
Message-ID: <20051122.144334.23915283.davem@davemloft.net>
References: <20051121213549.GA28187@ms2.inr.ac.ru>
	<E1EeJxb-0006xG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965080AbVKVWn3@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1EeJxb-0006xG-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 Nov 2005 09:16:27 +1100

> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> > 
> > I agree, apparently netlink_autobind was missed when sed'ing pid->tgid.
> > Of course, it does not matter, but tgid is nicer choice from user's viewpoint.
> 
> Great, here is the patch to do just that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, of course.

I can't for the life of me figure out how we missed this when
we fixed up all the current->pid references under net/.
Ulrich Drepper let us know that the problem existed, and
I was sure we eliminated all such cases.

It is possible we accidently reintroduced current->pid when
we redid all of the netlink hashing. :-)
