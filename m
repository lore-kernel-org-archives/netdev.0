From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 10:09:15 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>  <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>  <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>  <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>  <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
  <1110290300.1050.190.camel@jzny.localdomain>  <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
  <1110291470.1043.211.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
 <1110316631.1084.57.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1110316631.1084.57.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005, jamal wrote:

> Henrik, so what is the difference between this and using any random
> block of addresses?;-> If the packets never leave the box i can use
> IBM's block of addresses if i wanted - no need to sweat this far (with
> hacking the kernel).

Not if you want to maintain sane routing tables within the box and still 
be able for IBM to connect the box to their network. Some components of 
the box will need to sit both in the external and internal environments.

> If Zdenek is going to put more than one box then theres nothing magical;
> he will have to sit down and configure one of the boxes manually - no
> escape there.

No, as the packets never leaves his box in the first place there is no 
problem with multiple boxes. They will never share the internal network 
segment where the addresses are seen.

He is building a multi-node box (single box, multiple internal nodes, some 
external intefaces) using TCP/IP for the internal communication between 
the nodes within the box. For this communication he propose the use of a 
part of the 127/8 address space, but only for the communication within his 
multinode box. Not for communication visible outside of the box.

> If he puts only a single box then he may likely get away with it.
>
>>> Except this wont be practical for IPV4 since those addresses are scarce.
>>> May make sense for V6 though (becomes like MAC addresses on NICS).
>>
>> IPv6 already have link local addressing IIRC.
>>
>
> indeed that is what is needed in this case if the problem is address
> conflict resolution. An equivalent for v4 (called zeroconf) is at:
> http://www.zeroconf.org/

Unfortunately this does not apply to multihomed hosts, but provides an 
interesting address range which may be useable as an alternative to 127.X 
for the discussed purpose assuming hosts on the local network outside of 
the box is not using IPv4LL addresses in communication involving the box.

Regards
Henrik
