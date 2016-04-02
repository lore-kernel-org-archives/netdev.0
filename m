From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Sat, 02 Apr 2016 20:33:34 +0200
Message-ID: <1459622014.18188.2.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
	 <56FAAA6D.3070806@candelatech.com>
	 <1459329252.2055.1.camel@sipsolutions.net>
	 <20160330.123821.328761526754742195.davem@davemloft.net>
	 <56FC0445.6010200@candelatech.com>
	 <1459410405.4576.8.camel@sipsolutions.net>
	 <20160331075015.GA27716@gondor.apana.org.au>
	 <1459438199.4576.26.camel@sipsolutions.net>
	 <20160401004627.GA9367@gondor.apana.org.au>
	 <1459546450.3342.22.camel@sipsolutions.net>
	 <20160402014653.GA19235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160402014653.GA19235@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-04-02 at 09:46 +0800, Herbert Xu wrote:
> On Fri, Apr 01, 2016 at 11:34:10PM +0200, Johannes Berg wrote:
> > 
> > 
> > I was thinking about that one - it's not obvious to me from the
> > code
> > how this "explicitly checking for dups" would be done or let's say
> > how
> > rhashtable differentiates. But since it seems to work for Ben until
> > hitting a certain number of identical keys, surely that's just me
> > not
> > understanding the code rather than anything else :)
> It's really simple, rhashtable_insert_fast does not check for dups
> while rhashtable_lookup_insert_* do.

Oh, ok, thanks :)

johannes
