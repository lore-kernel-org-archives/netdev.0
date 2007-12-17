From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr)
	functions
Date: Mon, 17 Dec 2007 14:42:41 -0800
Message-ID: <1197931361.27386.67.camel@localhost>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
	 <Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3644 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954AbXLQWmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 17:42:45 -0500
In-Reply-To: <Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-12-17 at 23:37 +0100, Jan Engelhardt wrote:
> >+static inline bool ipv4_is_loopback(__be32 addr)
> >+{
> >+	return (addr & htonl(0xff000000)) == htonl(0x7f000000);
> >+}
> >+
> Can we use __constant_htonl()?

I believe the generated code is the same.

> >+static inline bool ipv4_is_private_10(__be32 addr)
> >+{
> >+	return (addr & htonl(0xff000000)) == htonl(0x0a000000);
> >+}
> 
> What are these functions needed for, even? There does not seem to be
> any code (at least in davem's net-2.6.25:net/ipv4/, where I dared to grep)
> that uses them.

include/net/addrconf.h
net/sctp/protocol.c

cheers, Joe

