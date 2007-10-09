From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 09 Oct 2007 09:27:38 +0200
Message-ID: <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au>
	 <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke> <20071009071338.GA15057@2ka.mipt.ru>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:31387 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752708AbXJIH1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 03:27:40 -0400
In-Reply-To: <20071009071338.GA15057@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-09 at 11:13 +0400, Evgeniy Polyakov wrote:
> On Tue, Oct 09, 2007 at 08:08:22AM +0200, Joakim Tjernlund (joakim.tjernlund@transmode.se) wrote:
> > > Your program works fine here.  You did run it as root, right?
> > 
> > Yes and ETH_P_ALL is the only protocol that prints anything
> > I am on 2.6.22
> 
> ETH_P_ARP works too.
> 
> > > Did you try stracing it?
> > 
> > Just did and now it works, it didn't yesterday :(
> > But if I change protocol to ETH_P_MOBITEX, I don't get any
> > pkgs(I did change protocol on sending side too)
> 
> Did you change eth_type_trans() to catch your proto?
> 

Just fond out something:
if I redirect my prog like so:
./sniff > log
and press Ctrl-C after a packet has been sent to it, 
it does NOT work. I don't get ANY output in my "log" file, not
even the printf("---------\n") appears.
But if I run whithout redirect it works(at least with ETH_P_BPQ)
Anyone else see this too?

  Jocke
