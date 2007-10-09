From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 9 Oct 2007 11:34:38 +0400
Message-ID: <20071009073437.GA1951@2ka.mipt.ru>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au> <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke> <20071009071338.GA15057@2ka.mipt.ru> <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41777 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbXJIHez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 03:34:55 -0400
Content-Disposition: inline
In-Reply-To: <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 09, 2007 at 09:27:38AM +0200, Joakim Tjernlund (joakim.tjernlund@transmode.se) wrote:
> > Did you change eth_type_trans() to catch your proto?
> > 
> 
> Just fond out something:
> if I redirect my prog like so:
> ./sniff > log
> and press Ctrl-C after a packet has been sent to it, 
> it does NOT work. I don't get ANY output in my "log" file, not
> even the printf("---------\n") appears.
> But if I run whithout redirect it works(at least with ETH_P_BPQ)
> Anyone else see this too?

I only tested with IP and ARP packets - I can not say when packet was
actually received and written to log, but it does start filling up, but
maybe not immediately - it can be output buffering in shell though.

-- 
	Evgeniy Polyakov
