From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 17:35:27 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029063527.2888C12C7AE@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All,

Just tried 2.4.20-pre11 and all NIC issues seem to be resolved.
Both eepro100 and e100 drivers work correctly.

			Paul

-----Original Message-----
From: Donald Becker [mailto:becker@scyld.com]
Sent: Tuesday, October 22, 2002 7:21 PM
To: Felipe W Damasio
Cc: Paul Hernandez; Jeff Garzik; Linux-net; netdev@oss.sgi.com
Subject: RE: NIC on 2.4.19 SMP (mii-diag output)


On 22 Oct 2002, Felipe W Damasio wrote:

> On Mon, 2002-10-21 at 15:16, Paul Hernandez wrote:
> >  I'm advertising 05e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD
> > 10baseT
> >    Advertising no additional info pages.
> >    IEEE 802.3 CSMA/CD protocol.
> >  Link partner capability is 0000:.
> >    Negotiation did not complete.
> 
> 	The link partner is not advertising it's capabilities.

No! There is not link partner.

0000 is the default value for the register when there is no negotiation
going on.
If you have link beat _and_ the register is 0000, then no
autonegotiation took place.
If the link partner advertised "not capable of anything", the register
will report 0001.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
