From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: send Change Status Report after DAD is completed
Date: Thu, 16 Jan 2014 13:24:09 +0100
Message-ID: <20140116122409.GC7436@order.stressinduktion.org>
References: <1389813008-23851-1-git-send-email-fbl@redhat.com> <52D7C0BA.7010908@redhat.com> <20140116122154.GK5359@plex.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42363 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaAPMYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 07:24:10 -0500
Content-Disposition: inline
In-Reply-To: <20140116122154.GK5359@plex.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 10:21:54AM -0200, Flavio Leitner wrote:
> > >diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > >index 99cd65c..8ac17f5 100644
> > >--- a/net/ipv6/mcast.c
> > >+++ b/net/ipv6/mcast.c
> > >@@ -1493,7 +1493,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
> > >  	skb_tailroom(skb)) : 0)
> > >
> > >  static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
> > >-	int type, int gdeleted, int sdeleted)
> > >+	int type, int gdeleted, int sdeleted, int crsend)
> > 
> > Maybe we should convert the last three to 'bool' at some point in time?
> 
> I'd say so.

Maybe it works out those can be one enum with a specified operation and no
bool vector?

Maybe you could have a look?

Thanks,

  Hannes
