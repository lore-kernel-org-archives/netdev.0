From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: add IPv6 SYNPROXY target
Date: Wed, 7 Aug 2013 22:57:18 +0200
Message-ID: <20130807205718.GB21463@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375897371-18430-6-git-send-email-kaber@trash.net>
 <20130807223440.0a40a7c1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48531 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab3HGU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 16:57:22 -0400
Content-Disposition: inline
In-Reply-To: <20130807223440.0a40a7c1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 10:34:40PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Wed,  7 Aug 2013 19:42:51 +0200 Patrick McHardy <kaber@trash.net> wrote:
> 
> > Add an IPv6 version of the SYNPROXY target. The main differences to
> > the IPv4 version is routing and IP header construction.
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> > +static int synproxy_tg6_check(const struct xt_tgchk_param *par)
> > +{
> > +	/// XXX PROTO match TCP
> 
> Ups, this looks like an comment to your self ;-)
> 
> > +	return nf_ct_l3proto_try_module_get(par->family);
> > +}

Oops right, I intended to add a check for proto TCP match in the rule
to make sure thoff is initialized by ip6tables.

I'll wait for more comments before sending an updated series.
