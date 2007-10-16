From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: Multicast problem
Date: Tue, 16 Oct 2007 23:15:06 +0200
Message-ID: <003201c81039$a0215b20$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David Stevens'" <dlstevens@us.ibm.com>,
	"'Netdev'" <netdev@vger.kernel.org>,
	"Li Yang" <LeoLi@freescale.com>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:54068 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932880AbXJPVPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:15:10 -0400
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> > > 
> > > OK, so from all this and earlier mail I think that the 
> > device driver don't
> > > receive multicast pkgs. Tomorrow I will try the real OSPF 
> > test case with
> > > promisc mode enabled, se if that works. If so, it means there is
> > > a bug in the drivers(ucc_geth.c) set_multicast_list() function.
> > > 
> > > Thank you for helping me to narrow it down.
> > > 
> > >  Jocke
> > 
> > You can test multicast easily standalone with iperf:
> > http://dast.nlanr.net/Projects/Iperf/#multicast
> > 
> 
> Thanks, will give it a try.
> 

Managed to cross compile iperf and ran the test. I need promisc mode
on the ethernet i/f to receive anything from that test so I guess this
confirms it, the set_multicast_list() in ucc_geth driver is broken.

Leo, forgot to CC you earlier. Seem like the multicast function
is somewhat buggy.

 Jocke


