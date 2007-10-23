From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error statistics.
Date: Tue, 23 Oct 2007 16:08:34 +0900
Message-ID: <200710231608.34661.nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net> <11930334662094-git-send-email-nakam@linux-ipv6.org> <1193056091.4422.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:55949 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbXJWHIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 03:08:44 -0400
In-Reply-To: <1193056091.4422.33.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Monday 22 October 2007 21:28, jamal wrote:
> On Mon, 2007-22-10 at 15:11 +0900, Masahide NAKAMURA wrote:
> > This patch introduces statistics about transformation error (or almost error)
> > factor at packet processing for developer.
> > It is not a SNMP/MIB specification from IPsec/MIPv6 but a counter
> > designed from current transformation source code.
> > 
> > Comment please.
> 
> very nice - these stats make IPSEC a lot more usable (I will go look and
> see if theres anything that i have used for debug before that you dont
> have and send you mail). Two comments:

Thanks. I would like you to find too much item at my patch
for the statistics, too.

> 1) Since these are not MIB stats, it sounds like a good idea not to use
> _MIB_ extender in the naming. Maybe something like _NOTMIB_ ;-> or
> totaly leave it out. One other approach is to push these to be a MIB at
> IETF since they are sensible to have.

This point is one of what I want to hear comment.
My patch uses "XFRM_MIB_XXX" because I found "LINUX_MIB_XXX" definition at
include/linux/snmp.h for TCP extended statistics at /proc/net/netstat and
it does not seem to be defined by any RFC specification. Then I feel it is not so bad to
use _MIB_ for them. Maybe we have another idea to merge them into LINUX_MIB.

Now we have the following candidates:

(1) my patch		XFRM_MIB_INHDRERROR
(2) some extender	XFRM_XXX_INHDRERROR	(XXX is requested)
(3) not-mib extender	XFRM_NOTMIB_INHDRERROR
(4) no extender		XFRM_INHDRERROR
(5) merge linux-mib	LINUX_MIB_XFRMINHDRERROR

Comments?


> 2) Why /proc? Are you going to make these available also via netlink? 

Because /proc is easy to see it without any modified application.
If you want the netlink interface, I can do it as the next step. Do you want it?

-- 
Masahide NAKAMURA
