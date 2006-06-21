From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 source address selection in addrconf.c (2.6.17)
Date: Wed, 21 Jun 2006 23:02:10 +0900 (JST)
Message-ID: <20060621.230210.11279657.yoshfuji@linux-ipv6.org>
References: <44986AE6.6090102@poczta.fm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:3592 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932163AbWFUOBS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 10:01:18 -0400
To: stlman@poczta.fm
In-Reply-To: <44986AE6.6090102@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <44986AE6.6090102@poczta.fm> (at Tue, 20 Jun 2006 23:38:46 +0200), Lukasz Stelmach <stlman@poczta.fm> says:

> Greetings.
> 
> net/ipv6/addrconf.c:971 is
> /* Rule 2: Prefer appropriate scope */
> if (hiscore.rule < 2) {
>         hiscore.scope = __ipv6_addr_src_scope(hiscore.addr_type);
>         hiscore.rule++;
> }
> 
> I am afraid, that it does not make any sense for I find no place where a value
> is assigned to hiscore.addr_type. There are some more references to
> hiscore.addr_type below but the only assignment is when the whole structure is
> cleaned with memset(3)

hiscore is copied from score.

--yoshfuji
