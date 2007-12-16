From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Sat, 15 Dec 2007 22:17:35 -0500
Message-ID: <bdfc5d6e0712151917k4adeaa34q3f498950883697ab@mail.gmail.com>
References: <bdfc5d6e0712150709k2dc0a845n84c494c519298f8d@mail.gmail.com>
	 <E1J3jE4-0000FE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl, fubar@us.ibm.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:20617 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbXLPDRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 22:17:37 -0500
Received: by fk-out-0910.google.com with SMTP id z23so685461fkz.5
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 19:17:35 -0800 (PST)
In-Reply-To: <E1J3jE4-0000FE-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 15, 2007 9:27 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> >
> > I agree with you completely, Herbet, which is why I was surprised that
> > my first apparently did not resolve the issue.  I felt it should
> > have....
>
> Did it change all occurrences of read_lock(&bond->lock) to
> read_lock_bh? If so I better look at the lockdep output again.
>

Not all of them in the bonding code, but all two of them in the small patch.
