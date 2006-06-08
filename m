From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite
 support
Date: Thu, 08 Jun 2006 23:38:16 +0900 (JST)
Message-ID: <20060608.233816.36365945.yoshfuji@linux-ipv6.org>
References: <200606081150.34018@this-message-has-been-logged>
	<1149778072.22124.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:6417 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964839AbWFHOhl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 10:37:41 -0400
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1149778072.22124.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1149778072.22124.6.camel@localhost.localdomain> (at Thu, 08 Jun 2006 15:47:52 +0100), Alan Cox <alan@lxorguk.ukuu.org.uk> says:

> Ar Iau, 2006-06-08 am 11:50 +0100, ysgrifennodd Gerrit Renker:
> > +  UDP-Lite introduces a new socket type, the SOCK_LDGRAM (note the L) for
> > +  lightweight, connection-less services. These are the socket options:
:
> 	s = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDPLITE);
> 
> is probably the right way to do this, keeping 0 "default" as before
> meaning IPPROTO_UDP

I do think so, too.

--yoshfuji
