From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 17 Aug 2003 15:55:28 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200308171555280781.0067FB36@192.168.128.16>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
 <20030728213933.F81299@coredump.scriptkiddie.org>
 <200308171509570955.003E4FEC@192.168.128.16>
 <200308171516090038.0043F977@192.168.128.16>
 <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
Content-Type: text/plain; charset="us-ascii"
Cc: "Lamont Granquist" <lamont@scriptkiddie.org>,
	"Bill Davidsen" <davidsen@tmr.com>,
	"David S. Miller" <davem@redhat.com>, bloemsaa@xs4all.nl,
	"Marcelo Tosatti" <marcelo@conectiva.com.br>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
List-Id: netdev.vger.kernel.org

On 17/08/2003 at 14:41 Alan Cox wrote:

>On Sul, 2003-08-17 at 14:16, Carlos Velasco wrote:
>> So,
>> 
>> According to RFC 1027:
>> http://www.ietf.org/rfc/rfc1027.txt
>
>Proxy ARP only.

So, if you have a router performing Proxy ARP... you don't need to
reply to the "bad" Linux ARP Request, right?

>>    A.3.  ARP datagram
>> 
>>       An ARP reply is discarded if the destination IP address does
not
>>       match the local host address.  
>
>Linux counts all the IP addresses it has as being local host address.

You should pay more attention, the real thing is on the second phrase:

"An ARP request is discarded if the source IP address is not in the
same subnet."

>And Linux btw has arpfilter which can do far more than just imitate
your
>favourite network religion of the week

And you can just use other OS and solve the problem without messing
with firewalling and mangling techniques.
Maybe the "favourite network religion" should be called as "RedHat
favourite network religion"?
Or maybe it should be called... "Linux approaching Microsoft", as both
don't listen to real users.

Linux versus all other OSes and systems (Cisco, Foundry, ...)
It's clear this is not MY religious war... maybe others war.... I don't
live from Linux.

Regards,
Carlos Velasco


