From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 9 Oct 2007 11:13:38 +0400
Message-ID: <20071009071338.GA15057@2ka.mipt.ru>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au> <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42346 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbXJIHNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 03:13:52 -0400
Content-Disposition: inline
In-Reply-To: <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 09, 2007 at 08:08:22AM +0200, Joakim Tjernlund (joakim.tjernlund@transmode.se) wrote:
> > Your program works fine here.  You did run it as root, right?
> 
> Yes and ETH_P_ALL is the only protocol that prints anything
> I am on 2.6.22

ETH_P_ARP works too.

> > Did you try stracing it?
> 
> Just did and now it works, it didn't yesterday :(
> But if I change protocol to ETH_P_MOBITEX, I don't get any
> pkgs(I did change protocol on sending side too)

Did you change eth_type_trans() to catch your proto?


-- 
	Evgeniy Polyakov
