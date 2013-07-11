From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 16:57:42 +0200
Message-ID: <51DEC7E6.8000500@6wind.com>
References: <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:61137 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549Ab3GKO5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 10:57:46 -0400
Received: by mail-wg0-f53.google.com with SMTP id y10so7297558wgg.32
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 07:57:44 -0700 (PDT)
In-Reply-To: <20130711144623.GA5707@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/07/2013 16:46, Hannes Frederic Sowa a =C3=A9crit :
> On Thu, Jul 11, 2013 at 12:24:41PM +0200, Hannes Frederic Sowa wrote:
>> I fear, I'll need to do a bit more research.
>
> My proposal is to take my patch and check for RTF_ADDRCONF plus RTF_D=
YNAMIC,
> too. The RTF_DYNAMIC check would prevent routes created from icmpv6 r=
edirects
> entering an ecmp route set.
>
> Do you agree?
Yes.


Regards,
Nicolas
