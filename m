From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [PATCH net-2.6.22] [IPV6] FIB6RULE: Find source address during
 looking up route.
Date: Wed, 28 Mar 2007 13:02:52 +0900 (JST)
Message-ID: <20070328.130252.719895987.takamiya@po.ntts.co.jp>
References: <20070327.224537.09436398.yoshfuji@linux-ipv6.org>
	<20070327142519.GN521@postel.suug.ch>
	<20070328.124940.55792158.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:35691 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbXC1E1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 00:27:20 -0400
In-Reply-To: <20070328.124940.55792158.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Wed, 28 Mar 2007 12:49:40 +0900 (JST)
>> [Subject: Re: [PATCH net-2.6.22] [IPV6] FIB6RULE: Find source address during looking up route.]
>> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote...

> > Out of curiosity, what sort of rules would have this flag set?
> > The majority of lookups don't provide a valid source address.
> > This new address search could become very expensive, because
> > none of the results are cached.
> 
> This flags is used for Mobile IPv6.
> 
> Well, for non-connected sockets on hosts, yes,
> the process might not be light-weight.
> But, on routers, or once the socket is connected,
> source address should be always set.

  Even if you set the rule which has the condition regarding as the
  source address, this rule is not selected for the first packet
  because the source address is not chosen yet.

  This fix is required to do source address based routing using
  fib6_rules.

#Even if the same routing with subtrees, the same problem is caused.

  Regards,

--
Noriaki TAKAMIYA
