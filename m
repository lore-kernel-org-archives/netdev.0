From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next,iproute2] netconf: add support for ignore route attribute
Date: Mon, 14 Mar 2016 16:31:24 +0800
Message-ID: <000301d17dcb$e549b0e0$afdd12a0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3377 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbcCNIb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 04:31:29 -0400
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 14 Mar 2016 04:55:36 +0000
> Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:
> 
> > Add support for ignore_routes_with_linkdown attribute.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  ip/ipnetconf.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c index eca6eee..6fec818
> > 100644
> > --- a/ip/ipnetconf.c
> > +++ b/ip/ipnetconf.c
> > @@ -119,6 +119,10 @@ int print_netconf(const struct sockaddr_nl *who,
> struct rtnl_ctrl_data *ctrl,
> >  		fprintf(fp, "proxy_neigh %s ",
> >  			*(int
> *)RTA_DATA(tb[NETCONFA_PROXY_NEIGH])?"on":"off");
> >
> > +	if (tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])
> > +		fprintf(fp, "ignore_routes_with_linkdown %s ",
> > +			*(int
> >
> +*)RTA_DATA(tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])?"on":"
> off");
> 
> This is a good idea.
> 
> But the option name is too long, and the code does not follow current best
> practices.
I agree with you that the name is too long, but I can't figure out a shorter
name. 
Any good suggestion? What about "ignore_routes" ? 

>   1. Lines are too long
>   2. There needs to be whitespace around ? :
>   3. There are helper routines (rte_getattr_XXX) which should be used
rather
> than
>      cast RTE_DATA directly.
> 
> Also, help and man page??
Yes, man page need to be enhanced.
