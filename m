From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Fri, 01 Apr 2016 23:34:10 +0200
Message-ID: <1459546450.3342.22.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
	 <56FAAA6D.3070806@candelatech.com>
	 <1459329252.2055.1.camel@sipsolutions.net>
	 <20160330.123821.328761526754742195.davem@davemloft.net>
	 <56FC0445.6010200@candelatech.com>
	 <1459410405.4576.8.camel@sipsolutions.net>
	 <20160331075015.GA27716@gondor.apana.org.au>
	 <1459438199.4576.26.camel@sipsolutions.net>
	 <20160401004627.GA9367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160401004627.GA9367@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-04-01 at 08:46 +0800, Herbert Xu wrote:
> On Thu, Mar 31, 2016 at 05:29:59PM +0200, Johannes Berg wrote:
> > 
> > 
> > Does removing this completely disable the "-EEXIST" error? I can't
> > say
> > I fully understand the elasticity stuff in
> > __rhashtable_insert_fast().
> What EEXIST error are you talking about? The only one that can be
> returned on insertion is if you're explicitly checking for dups
> which clearly can't be the case for you.

I was thinking about that one - it's not obvious to me from the code
how this "explicitly checking for dups" would be done or let's say how
rhashtable differentiates. But since it seems to work for Ben until
hitting a certain number of identical keys, surely that's just me not
understanding the code rather than anything else :)

johannes
