From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][SCTP] Re: lockdep: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist (2.6.21-rc1)
Date: Thu, 8 Mar 2007 12:15:21 +0100
Message-ID: <20070308111521.GA3228@ff.dom.local>
References: <20070308074751.GA2085@ff.dom.local> <E1HPGMB-0002AG-00@gondolin.me.apana.org.au> <20070308110230.GA9175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@arlott.org, linux-kernel@vger.kernel.org, sri@us.ibm.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:34726 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751161AbXCHLLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 06:11:21 -0500
Content-Disposition: inline
In-Reply-To: <20070308110230.GA9175@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 10:02:30PM +1100, Herbert Xu wrote:
> On Thu, Mar 08, 2007 at 10:00:23PM +1100, Herbert Xu wrote:
> > 
> > Who's calling ipv6_add_addr from softirq context? That's got to be
> > wrong because ipv6_add_addr requires the RTNL.
> 
> Nevermind, I was thinking of ipv6_add_dev.

Anyway - maybe I forgot to say - the full error message
available on linux-kernel.

Cheers,
Jarek P.
