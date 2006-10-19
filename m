From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: (usagi-core 31424) Re: [PATCH 7/13] [RFC] [IPV6] Move source
 address selection into route lookup.
Date: Thu, 19 Oct 2006 09:28:14 +0300
Message-ID: <45371AFE.9030704@tcs.hut.fi>
References: <20061016.222223.26532234.davem@davemloft.net>	<45348DD4.4000600@6wind.com>	<20061017.175231.45194288.yoshfuji@linux-ipv6.org> <20061018.230850.91573842.yoshfuji@linux-ipv6.org> <4536E279.1090003@jp.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, davem@davemloft.net, tgraf@suug.ch,
	kim.nordlund@nokia.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jean-mickael.guerin@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:31240 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1161289AbWJSG2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 02:28:18 -0400
To: Mitsuru Chinen <mitch@jp.ibm.com>
In-Reply-To: <4536E279.1090003@jp.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/06 05:27, Mitsuru Chinen wrote:

Hello Mitsuru-san,

> At the first Echo Request, its source address is a global address.
> 
> | # ping6 -n -c 1 -i 1 -s 1452 -p 00 -w 2 -I eth1 FF1E: :1:2
> | PATTERN: 0x00
> | PING FF1E::1:2(ff1e::1:2) from 3ffe:501:ffff:100:2d0:b7ff:fe9a:455b eth1: 1452 data bytes
> |
> | --- FF1E::1:2 ping statistics ---
> | 3 packets transmitted, 0 received, 100% loss, time 1999ms
> 
> However, after receiving a Too Big message, the source address
> of Echo Request is changed to :: at the failure case.

thank you for the thorough test report! I'll try to track down the reason.

Regards,
Ville
