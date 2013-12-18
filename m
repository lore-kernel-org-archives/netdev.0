From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] netconf: rename PROXY_ARP to NEIGH_PROXY
Date: Wed, 18 Dec 2013 10:06:06 -0800
Message-ID: <20131218100606.4eee45fb@nehalam.linuxnetplumber.net>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
	<52B1D625.5060002@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:36911 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358Ab3LRSGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 13:06:10 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so8826396pbc.27
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 10:06:10 -0800 (PST)
In-Reply-To: <52B1D625.5060002@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 12:06:45 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 12/18/13 01:35, Stephen Hemminger wrote:
> > Use same field for both IPv4 (proxy_arp) and IPv6 (proxy_ndp)
> > so fix it before API is set to be a common name
> >
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >
> > ---
> >   include/uapi/linux/netconf.h |    2 +-
> >   net/ipv4/devinet.c           |   10 +++++-----
> >   2 files changed, 6 insertions(+), 6 deletions(-)
> >
> > --- a/include/uapi/linux/netconf.h	2013-12-17 22:30:00.000000000 -0800
> > +++ b/include/uapi/linux/netconf.h	2013-12-17 22:31:07.973419694 -0800
> > @@ -14,7 +14,7 @@ enum {
> >   	NETCONFA_FORWARDING,
> >   	NETCONFA_RP_FILTER,
> >   	NETCONFA_MC_FORWARDING,
> > -	NETCONFA_PROXY_ARP,
> > +	NETCONFA_PROXY_NEIGH,
> >   	__NETCONFA_MAX
> >   };
> 
> Can you do this? ;-> Why not #define NETCONFA_PROXY_NEIGH to be 
> NETCONFA_PROXY_ARP
> 
> cheers,
> jamal
> 

The patch is against un-released net-next and only changes something
that was just added.
