From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6,IPV4]: Fix several sparse warnings.
Date: Tue, 22 Jan 2008 02:44:19 -0800 (PST)
Message-ID: <20080122.024419.39724872.davem@davemloft.net>
References: <20080122.185632.09970660.yoshfuji@linux-ipv6.org>
	<20080122110312.10445043.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757379AbYAVKoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 05:44:12 -0500
In-Reply-To: <20080122110312.10445043.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 22 Jan 2008 11:03:12 +0100

> On Tue, 22 Jan 2008 18:56:32 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明  <yoshfuji@linux-ipv6.org> wrote:
> 
> > @@ -418,7 +418,7 @@ out:
> >  
> >  void udp_err(struct sk_buff *skb, u32 info)
> >  {
> > -	return __udp4_lib_err(skb, info, udp_hash);
> > +	__udp4_lib_err(skb, info, udp_hash);
> >  }
> 
> Hum... On this one, I would say Sparse is picky, not to say buggy :(

Agreed, but making this change is harmless :-)
