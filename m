From: Donald Becker <becker@scyld.com>
Subject: RE: NIC on 2.4.19 SMP (mii-diag output)
Date: Tue, 22 Oct 2002 22:20:50 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210222218200.1190-100000@beohost.scyld.com>
References: <1035323389.714.33.camel@tank>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Hernandez <ph@digitalquake.com>, Jeff Garzik <jgarzik@pobox.com>,
   Linux-net <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe W Damasio <felipewd@terra.com.br>
In-Reply-To: <1035323389.714.33.camel@tank>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
