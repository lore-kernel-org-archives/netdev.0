From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH 02/13] TProxy: add lookup type checks for UDP in
 nf_tproxy_get_sock_v4()
Date: Tue, 22 Sep 2009 08:40:13 +0200
Message-ID: <1253601613.6883.7.camel@bzorp.balabit>
References: <1253548005.12519.2.camel@bzorp.balabit>
	 <alpine.LSU.2.00.0909212320150.31023@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:47115 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755204AbZIVGkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 02:40:13 -0400
In-Reply-To: <alpine.LSU.2.00.0909212320150.31023@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-21 at 23:20 +0200, Jan Engelhardt wrote:
> On Saturday 2009-08-15 14:01, Balazs Scheidler wrote:
> 
> >+	case IPPROTO_UDP:
> >+		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
> >+				     in->ifindex);
> 
> You might want to add IPPROTO_UDPLITE in all places.

Well, I preferred not to add those, as I'm unable to test it, and I'd
prefer to submit a patch that really works for UDP and TCP at the
minimum. Further protocols (like SCTP) should be added later IMHO.

-- 
Bazsi

