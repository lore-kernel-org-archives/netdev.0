From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Mon, 25 Feb 2008 12:29:03 +0000
Message-ID: <1203942544.2979.7.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
	 <1203431447.3223.33.camel@shinybook.infradead.org>
	 <47BAEB6C.1030609@trash.net>
	 <1203666762.5771.35.camel@shinybook.infradead.org>
	 <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org>
	 <47BEEDEF.5060503@trash.net>
	 <1203719866.5771.81.camel@shinybook.infradead.org>
	 <47C2B09A.1040102@trash.net>
	 <1203941832.2979.0.camel@shinybook.infradead.org>
	 <47C2B29A.5090100@trash.net>
	 <1203942105.2979.2.camel@shinybook.infradead.org>
	 <47C2B33E.2020608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39710 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbYBYM3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 07:29:14 -0500
In-Reply-To: <47C2B33E.2020608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-02-25 at 13:23 +0100, Patrick McHardy wrote:
> David Woodhouse wrote:
> > On Mon, 2008-02-25 at 13:20 +0100, Patrick McHardy wrote:
> >> Right, I missed that. In that case the current headers should match
> >> the kernel headers (with the compiler.h part removed).
> > 
> > They don't. When you run 'make headers_install' there are some missing.
> 
> 
> We don't need all of them, but I'll do a proper resync. Thanks.

I think we need some of them -- when I just dropped the results of 'make
headers_install' into the iptables build directory, it complained of a
number of them being missing (which I showed a few days ago).

Ideally, the contents of the include/linux/ directory in the iptables
tree would be identical to what you get in usr/include/linux/netfilter*
after running 'make headers_install'.

-- 
dwmw2

