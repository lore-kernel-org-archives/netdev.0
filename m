From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: make br_parse_ip_options  static
Date: Tue, 19 Oct 2010 07:55:03 -0700
Message-ID: <20101019075503.057dd8d6@nehalam>
References: <20101018170321.2b0de4ea@nehalam>
	<20101019112234.GB12005@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36299 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab0JSOzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 10:55:06 -0400
In-Reply-To: <20101019112234.GB12005@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Oct 2010 07:22:34 -0400
Bandan Das <bandan.das@stratus.com> wrote:

> On  0, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/bridge/br_netfilter.c	2010-10-18 17:01:36.903364885 -0700
> > +++ b/net/bridge/br_netfilter.c	2010-10-18 17:01:48.106569141 -0700
> > @@ -213,7 +213,7 @@ static inline void nf_bridge_update_prot
> >   * expected format
> >   */
> >  
> > -int br_parse_ip_options(struct sk_buff *skb)
> > +static int br_parse_ip_options(struct sk_buff *skb)
> >  {
> >  	struct ip_options *opt;
> >  	struct iphdr *iph;
> > 
> 
> My main motivation behind not making this static was that
> there would be possibly other places in the bridge code 
> (besides br_netfilter.c) where we enter the IP stack and might 
> want to call this. Not sure if it's indeed the case though..
> 

I checked by doing make allmodconfig as well as looking by
git grep 'br_parse_ip_options'

-- 
