From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] snmp: add align parameter to
 snmp_mib_init()
Date: Fri, 25 Jun 2010 21:34:28 -0700 (PDT)
Message-ID: <20100625.213428.108798305.davem@davemloft.net>
References: <1277276321.2591.755.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	acme@ghostprotocols.net, vladislav.yasevich@hp.com,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219Ab0FZEeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:34:15 -0400
In-Reply-To: <1277276321.2591.755.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jun 2010 08:58:41 +0200

> In preparation for 64bit snmp counters for some mibs,
> add an 'align' parameter to snmp_mib_init(), instead
> of assuming mibs only contain 'unsigned long' fields.
> 
> Callers can use __alignof__(type) to provide correct
> alignment.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
