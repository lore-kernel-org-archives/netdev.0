From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2.6.24] fib_trie: apply fixes from fib_hash
Date: Sat, 26 Jan 2008 11:46:43 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0801261031300.3854@u.domain.uli>
References: <Pine.LNX.4.58.0801260427400.12635@u.domain.uli>
 <20080126051815.GA17278@ehus.geninetworks.com>
 <b25c3fa70801252120v1b928b15pd5a4e7bd2934161b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@data.slu.se>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>, schwab@suse.de
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:46703 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752769AbYAZJqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2008 04:46:31 -0500
In-Reply-To: <b25c3fa70801252120v1b928b15pd5a4e7bd2934161b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 26 Jan 2008, Joonwoo Park wrote:

> > >       Not tested, someone please check the findings

	news: simple testing of patched fib_trie seems to work

> > > -                     if (fi->fib_treeref > 1)
> > > +                     fa = fa_first;
> > > +                     if (fa_match && fa != fa_match)
> > >                               goto out;
> > > -
> >
> > Isn't it possible to do this (fib_hash too)?
> >                        if (fa_match) {
> >                                if (fa != fa_match)
> Sorry!
>                                   if (fa == fa_match)
> >                                        return 0;
> >                                goto out;
> >                        }

	I see, your idea is to optimize the case when matched
parameters are same. Considering the used fi is same I don't see
any problems. I'll prepare 2nd version of both patches in
next hours.

Regards

--
Julian Anastasov <ja@ssi.bg>
