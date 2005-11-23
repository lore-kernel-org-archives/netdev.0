From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK]: Use tgid instead of pid for nlmsg_pid
Date: Tue, 22 Nov 2005 22:18:00 -0800 (PST)
Message-ID: <20051122.221800.53590951.davem@davemloft.net>
References: <E1EeJxb-0006xG-00@gondolin.me.apana.org.au>
	<20051122.144334.23915283.davem@davemloft.net>
	<20051123000337.GA17249@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030330AbVKWGTR@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20051123000337.GA17249@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 23 Nov 2005 11:03:37 +1100

> On Tue, Nov 22, 2005 at 02:43:34PM -0800, David S. Miller wrote:
> > It is possible we accidently reintroduced current->pid when
> > we redid all of the netlink hashing. :-)
> 
> I just checked using git-whatchanged and that line goes back to
> 2002 :)

Ho hum, I guess we just missed it on the current->pid
scan then :-)
