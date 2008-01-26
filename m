From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 2.6.24] fib_trie: apply fixes from fib_hash
Date: Sat, 26 Jan 2008 14:20:27 +0900
Message-ID: <b25c3fa70801252120v1b928b15pd5a4e7bd2934161b@mail.gmail.com>
References: <Pine.LNX.4.58.0801260427400.12635@u.domain.uli>
	 <20080126051815.GA17278@ehus.geninetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Robert Olsson" <robert.olsson@data.slu.se>,
	netdev@vger.kernel.org, "Joonwoo Park" <joonwpark81@gmail.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Jarek Poplawski" <jarkao2@gmail.com>, schwab@suse.de
To: "Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:49233 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbYAZFUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 00:20:31 -0500
Received: by rv-out-0910.google.com with SMTP id k20so998704rvb.1
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 21:20:27 -0800 (PST)
In-Reply-To: <20080126051815.GA17278@ehus.geninetworks.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/1/26, Joonwoo Park <joonwpark81@gmail.com>:
> On Sat, Jan 26, 2008 at 04:40:30AM +0200, Julian Anastasov wrote:
> >
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >
> >       Not tested, someone please check the findings
> >
> > --- linux-2.6.24/net/ipv4/fib_trie.c_orig     2008-01-25 10:45:06.000000000 +0200
> > +
> >               if (cfg->fc_nlflags & NLM_F_REPLACE) {
> >                       struct fib_info *fi_drop;
> >                       u8 state;
> >
> > -                     if (fi->fib_treeref > 1)
> > +                     fa = fa_first;
> > +                     if (fa_match && fa != fa_match)
> >                               goto out;
> > -
>
> Isn't it possible to do this (fib_hash too)?
>                        if (fa_match) {
>                                if (fa != fa_match)
Sorry!
                                  if (fa == fa_match)
>                                        return 0;
>                                goto out;
>                        }
>
> Thanks,
> Joonwoo
>
