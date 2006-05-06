From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Sat, 06 May 2006 11:39:04 +0900 (JST)
Message-ID: <20060506.113904.63157190.yoshfuji@linux-ipv6.org>
References: <1146862832.2766.54.camel@pmac.infradead.org>
	<20060506.091920.122414672.yoshfuji@linux-ipv6.org>
	<1146876802.2503.32.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38917 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751802AbWEFCjE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 22:39:04 -0400
To: dwmw2@infradead.org
In-Reply-To: <1146876802.2503.32.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1146876802.2503.32.camel@shinybook.infradead.org> (at Sat, 06 May 2006 01:53:21 +0100), David Woodhouse <dwmw2@infradead.org> says:

> There is a default route, because I believe that's the only thing that
> radvd can do. I cannot advertise a route to _only_ fec0::/16, can I?

Yes, you can, via Route Information option.
(>= 2.6.17-rc1 support this.)

Anyway, it is valid to use (obsolete) site-local source address
for global destination address.
The problem seems that router does NOT send ICMPv6 destination
unreachable to the sender. I don't know why, but it SHOULD.

--yoshfuji
