From: James Morris <jmorris@intercode.com.au>
Subject: Re: Tigon 3 driver & Netgear GA302T
Date: Fri, 26 Apr 2002 20:14:47 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0204262009460.17951-100000@blackbird.intercode.com.au>
References: <Mutt.LNX.4.44.0204250152190.11349-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
In-Reply-To: <Mutt.LNX.4.44.0204250152190.11349-100000@blackbird.intercode.com.au>
List-Id: netdev.vger.kernel.org

On Thu, 25 Apr 2002, James Morris wrote:

> On 24 Apr 2002, Jes Sorensen wrote:
> 
> > >>>>> "James" == James Morris <jmorris@intercode.com.au> writes:
> > 
> > James> Does the tg3 driver support the Netgear GA302T card (which I
> > James> think uses the Altima AC1000 chip) ?
> > 
> > If it's the Altima then I guess so, otherwise I'd expect the 83820
> > driver to run it.
> > 
> 
> It appears to be the Altima, from the Freebsd cvs log comments & 
> associated changes for their bge driver.
> 

Confirmed:

eth2: Tigon3 [partno(BAC91000A1) rev 7104 PHY(5411)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet 00:40:f4:35:f1:77
eth2: Link is up at 100 Mbps, full duplex.
eth2: Flow control is off for TX and off for RX.

Unfortunately, it's not successfully transmitting or receiving any 
packets.


- James
-- 
James Morris
<jmorris@intercode.com.au>
