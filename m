From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH 4/9] tproxy: added tproxy sockopt interface in the IPV6
 layer
Date: Thu, 21 Oct 2010 10:46:21 +0200
Message-ID: <1287650781.13326.1.camel@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.78508.stgit@este.odu>
	 <alpine.LNX.2.01.1010211037520.22922@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010211037520.22922@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2010-10-21 at 10:39 +0200, Jan Engelhardt wrote:
> On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> 
> >@@ -268,6 +268,10 @@ struct in6_flowlabel_req {
> > /* RFC5082: Generalized Ttl Security Mechanism */
> > #define IPV6_MINHOPCOUNT		73
> > 
> >+#define IPV6_ORIGDSTADDR        74
> >+#define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
> >+#define IPV6_TRANSPARENT        75
> >+
> 
> Why do we actually need two names for the same thing?

IPV6_RECVORIGDSTADDR is the name of the socket option you're supposed to
set if you require the original destination address. IPV6_ORIGDSTADDR is
the name of the ancillary message you get with the actual address in it.
Just like we have it for IP_TOS/IP_RECVTOS, for example.

--KK



