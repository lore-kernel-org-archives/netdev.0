From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v5 8/8] 6lowpan: handling 6lowpan fragmentation
 via inet_frag api
Date: Thu, 27 Feb 2014 22:16:54 +0100
Message-ID: <20140227211652.GA29339@omega>
References: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
 <1393488382-1250-9-git-send-email-alex.aring@gmail.com>
 <20140227.155639.1203195193096437286.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:41893 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbaB0VRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:17:00 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so2129210eae.37
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 13:16:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140227.155639.1203195193096437286.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Feb 27, 2014 at 03:56:39PM -0500, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Thu, 27 Feb 2014 09:06:22 +0100
> 
> > +static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
> > +			     struct sk_buff *skb, const u8 frag_type,
> > +			     const struct ieee802154_frag_info *frag_info)
> 
> The 'frag_info' argument is unused.  You always explicitly access
> mac_cb()->frag_info here.

You are absolutly right, sorry for that. I will remove this parameter
instead of using frag_info than mac_cb(skb)->frag_info... because I
compare with some other sk buffs like mac(next)->frag_info. This will be
more easier to read.

Thanks.

- Alex
