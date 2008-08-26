From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 22:44:56 +0200
Message-ID: <48B46B48.7030609@cosmosbay.com>
References: <200808220457.40892.denys@visp.net.lb> <20080826201406.GA24827@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:44390 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbYHZUpI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 16:45:08 -0400
In-Reply-To: <20080826201406.GA24827@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Fri, Aug 22, 2008 at 04:57:40AM +0300, Denys Fedoryshchenko (denys=
@visp.net.lb) wrote:
>> I have loaded router (~650 Mbps In+Out), based on 2xAMD Opteron 248,=
 Sun Fire=20
>> X4100. HPET timer available (TSC seems not available on this platfor=
m).
>> Network interfaces is onboard, connected over PCI-X.
>>
>> Right now i am using only one processor, cause using only one interf=
ace and=20
>> interrupts stick to it. Other is almost not used.
>> At peak time i notice in mpstat, that this processor is almost "dead=
", and if=20
>> i run minor application consuming resources - ping over this router =
will be=20
>> terrible. For me it is clear - system overloaded. I did oprofile, an=
d here is=20
>> result (at low load time, but at peak time it is very similar).
>=20
> Do you have any packet sockets in this system? Like running dhcp daem=
on?
>=20

Another way to see this problem can be to start a sniffer on the machin=
e, even with a=20
restrictive pcap filter, to check if performance change or not. (It sho=
uld decrease)

=46or example, I believe that running "ping" could have the same effect
(increasing netstamp_needed variable : every incoming packet has to be =
timestamped)

So beware of pings, traceroute and other networking tools...



