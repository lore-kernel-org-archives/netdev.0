From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 4/9] tproxy: added tproxy sockopt interface in the IPV6
 layer
Date: Fri, 22 Oct 2010 06:09:37 +0900
Message-ID: <1287695377.2707.9.camel@takos>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.78508.stgit@este.odu>
	 <alpine.LNX.2.01.1010211037520.22922@obet.zrqbmnf.qr>
	 <1287650781.13326.1.camel@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38325 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751464Ab0JUVJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:09:38 -0400
In-Reply-To: <1287650781.13326.1.camel@este.odu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-10-21, KOVACS Krisztian wrote:
> Hi,
> 
> On Thu, 2010-10-21 at 10:39 +0200, Jan Engelhardt wrote:
> > On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> > 
> > >@@ -268,6 +268,10 @@ struct in6_flowlabel_req {
> > > /* RFC5082: Generalized Ttl Security Mechanism */
> > > #define IPV6_MINHOPCOUNT		73
> > > 
> > >+#define IPV6_ORIGDSTADDR        74
> > >+#define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
> > >+#define IPV6_TRANSPARENT        75
> > >+
> > 
> > Why do we actually need two names for the same thing?
> 
> IPV6_RECVORIGDSTADDR is the name of the socket option you're supposed to
> set if you require the original destination address. IPV6_ORIGDSTADDR is
> the name of the ancillary message you get with the actual address in it.
> Just like we have it for IP_TOS/IP_RECVTOS, for example.

I agree.

--yoshfuji

