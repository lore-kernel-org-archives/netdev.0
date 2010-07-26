From: Stuart Sheldon <stu@actusa.net>
Subject: Re: IPv6 Anycast?
Date: Mon, 26 Jul 2010 14:40:01 -0700
Message-ID: <4C4E00B1.1030300@actusa.net>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se> <4C491AD4.9070103@actusa.net> <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se> <4C49B163.8090400@actusa.net> <4C49C352.6010701@astaro.com> <4C49C92D.30705@actusa.net> <20100726084418.GA14903@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ulrich Weber <uweber@astaro.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>, netdev@vger.kernel.org,
	Stuart Sheldon <stu@actusa.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:34201 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab0GZVkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 17:40:20 -0400
In-Reply-To: <20100726084418.GA14903@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Hi Simon,

I found the ip man entry too... It appears that the code is in the
kernel, as it does automatically add the anycast addresses when you
start IPv6 routing...

Is this something I should file as a bug / feature request? I would
think this should be part of the iproute2 stuff, but LARTC seems to have
fallen off the planet. I'm an Administrator not really a programmer, and
this seems way beyond my hacking to get done. Not really sure where to
go from here...

Does anyone out there have any suggestions???

Thanks in advance...

Stu


Simon Horman wrote:
> On Fri, Jul 23, 2010 at 09:54:05AM -0700, Stuart Sheldon wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA256
>>
>> Hi Ulrich,
>>
>> Thanks, that resolves half the issue. So as of right now, there is no
>> userspace program to add anycast addresses?
> 
> I was hoping to have some useful information, but alas I failed on that count.
> 
> Looking at ip(8) it seems that the following ought to work:
> 
> ip addr add fd16:a2f5:c4d7::7/48 anycast fd16:a2f5:c4d7::8 dev eth0
> 
> However, it seems not to, and then I found this in the manpage :-(
> 
> 	anycast   -   not  implemented  the  destinations are  anycast
> 	addresses assigned to this host.  They are mainly equivalent to
> 	local with one difference: such addresses are invalid when used as
> 	the source address of any packet.
> 


- --
Does anyone know where the love of God goes when the waves turn the
minutes to hours. The searchers all say that they'd have made
White Fish Bay if they'd put fifteen more miles behind her.
   -- Gordon Lightfoot "The Wreck of The Edmund Fitzgerald Lyrics"
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAEBCAAGBQJMTgCxAAoJEFKVLITDJSGSuYMQAKEu/uogchQpUhtHgsYUtDfl
AJbSo+dLJMKnucb5j8p1+bVM32DFwAP3xC7PuFi3apQywwQljjHJSti4E2oQlM5T
GBkCD6+CJS15sg6HG7mJNcBceLhOYlGhRGIA6AXM+O9hGKnQAcW3i/A9gQvhj1oQ
gcC94gjJTf0Fk+/jvqpZs20+jTkM6mhtOHG93dCLmKnKDKpTpJjgjWXcBqinYGft
+jJZ8WZwAHWKd5hlzkcfK8+b7TlifNq+3ymfeJt/aZHynu7tiGUTLRTWddC3wcSj
QMjQkT/w49BeZd4LPOvuXRIoH7cy4Tr5gc6HP5o9b3j5VSlbZMhaRP2l/iLncp3v
LB0lsENDPRz2VT4eS/yJCDs7JUqg0yCeCk33qkoN0lFqau6AWbDeDuaX2wwyolY+
23sezJXolk0iZXGSK7XRfdhnfW1xTmPH/7QR0oPkKt1l+sSUcoIEzkXkTXD1VpRm
L6uga2GP7JPjOHKBpgDR97FFjsMRQqin7fPp36pLWY2risb1dXNUYcKp9bzFdGtm
u8R2j4g5WS5uGgwE08DSN/bQasBP6QaqD2GPH7GTYsDjiDwvk1UKKEPMYybryWGQ
sFn4+gB2n/Z7oNT+6Y+VrcnFV6BFSzrsi2DmUxRWuGMEHjKjm6wfpGoBa0WT9esL
Tz1B5/1tbsCtvGQ2ZwXI
=jGSQ
-----END PGP SIGNATURE-----
