From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP sacked_out and fackets_out inconsistency (Was: Re: BUG:
 unable to handle kernel NULL pointer dereference at 000000000000002c)
Date: Wed, 08 Feb 2012 10:15:13 +0100
Message-ID: <1328692513.2284.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
	  <4F2A87B0.6070900@profihost.ag>
	  <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <20120202.143957.2251106530056768980.davem@davemloft.net>
	  <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>
	  <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>
	  <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <20120203155309.GB20638@kroah.com> <4F2F9784.7090203@profihost.ag>
	 <1328519990.2220.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1202061151580.2966@wel-95.cs.helsinki.fi>
	 <4F3231C1.9040509@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, Netdev <netdev@vger.kernel.org>,
	david@fromorbit.com, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64919 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab2BHJPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 04:15:17 -0500
In-Reply-To: <4F3231C1.9040509@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 f=C3=A9vrier 2012 =C3=A0 09:26 +0100, Stefan Priebe - Pr=
ofihost AG
a =C3=A9crit :
> Hi Eric,

> What do you think about this? Can anybody give me the commit id?
>=20
> Stefan

commit 5b35e1e6e9ca651e6b291c96d1106043c9af314a
Author: Neal Cardwell <ncardwell@google.com>
Date:   Sat Jan 28 17:29:46 2012 +0000

    tcp: fix tcp_trim_head() to adjust segment count with skb MSS



Its quite recent and David will push it to stable, dont worry.
