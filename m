From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] netpoll: fix netconsole IPv6 setup
Date: Thu, 6 Feb 2014 21:58:50 +0100
Message-ID: <20140206205850.GA12704@kria>
References: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
 <CAHA+R7OQYZ5RLn3v0nucKB=CVpDCZqp=HyNL=qgC9bViVKEuAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:58452 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbaBFU7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 15:59:02 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7OQYZ5RLn3v0nucKB=CVpDCZqp=HyNL=qgC9bViVKEuAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-06, 12:34:10 -0800, Cong Wang wrote:
> On Thu, Feb 6, 2014 at 9:34 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> >  net/core/netpoll.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index c03f3de..a664f78 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -948,6 +948,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
> >  {
> >         char *cur=opt, *delim;
> >         int ipv6;
> > +       bool ipversion_set = false;
> >
> 
> Or initialize 'ipv6' to -1 and then check if it is -1?

It's overwritten when we parse the remote address. And np->ipv6 is a
bool, so we can't store it there either.

-- 
Sabrina
