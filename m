From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 4/6] 6lowpan: fix some checkpatch issues
Date: Fri, 21 Feb 2014 18:15:02 +0100
Message-ID: <20140221171500.GA18373@omega>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
 <1392995711-19563-5-git-send-email-alex.aring@gmail.com>
 <1393001937.2594.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, martin.townsend@xsilon.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51853 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbaBURPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 12:15:10 -0500
Received: by mail-ee0-f46.google.com with SMTP id c13so1736775eek.19
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 09:15:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393001937.2594.18.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Feb 21, 2014 at 08:58:57AM -0800, Joe Perches wrote:
> On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> > diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
> []
> > @@ -484,8 +475,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
> >  		err = lowpan_fragment_xmit(skb, head, header_length, len,
> >  					   offset, LOWPAN_DISPATCH_FRAGN);
> >  		if (err) {
> > -			pr_debug("%s unable to send a subsequent FRAGN packet "
> > -				 "(tag: %d, offset: %d", __func__, tag, offset);
> > +			pr_debug("%s unable to send a FRAGN packet.", __func__);
> > +			pr_debug("tag: %d, offset: %d", tag, offset);
> 
> No need for 2 pr_debug statements.
> 
> Better to coalesce the format pieces into a single string
> adding the close parenthesis and a terminating newline.
> 
> 			pr_debug("%s: unable to send a subsequent FRAGN packet "(tag: %d, offset: %d)\n",
> 				 __func__, tag, offset);
ah ok, thanks I will fix it.

- Alex
