From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 18:54:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307241849341.2177-100000@l>
References: <200307241728270476.0031BAB0@192.168.128.16>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bart De Schuymer <bdschuym@pandora.be>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200307241728270476.0031BAB0@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 24 Jul 2003, Carlos Velasco wrote:

> The problem is more complicated than the simplified setting I have builded for describing the bug:
> Real setting and meaning of the lo interface is because I'm using IOS Load Balancing in dispatched mode on Cisco Catalyst 6500.
> This cause packets being sent to a server farm of Linux boxes with destination IP the one configured on the loopback interface in all machines.
> In the ethernet interface all Linux boxes have diferent IP address and the balancing device send the packets through any of these interfaces, choosing the "leastconnections" server.
> Thus, the load balancing device only change the mac address of the real packet on the fly sending it to one of the real servers where it's accepted cause of destination IP is the loopback IP address on every Linux machine.
>
> Problem is when the packet go back to the balancing device, as they send ARP request with loopback source IP address, that cause Cisco device not to reply the ARP request.
> I have tried different IOS and Cisco devices, no one reply this ARP request.

	I now see, it is the so called "ARP Problem" in the IPVS
context, many real servers and one director sharing same virtual
IP:

http://www.linuxvirtualserver.org/

The most used feature for such setups:
http://www.ssi.bg/~ja/#hidden

> Regards,
> Carlos Velasco

Regards

--
Julian Anastasov <ja@ssi.bg>
