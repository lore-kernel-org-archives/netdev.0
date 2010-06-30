From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: Re: nat bypass
Date: Wed, 30 Jun 2010 14:54:32 +0530
Message-ID: <AANLkTilxqHHiDfzQbewBe8cnTtvdB9CCTPn9EVCcAf5Q@mail.gmail.com>
References: <AANLkTil_H1QeaCHQYhMjVRFiLwtqF9yLAJZ9BWecOIDW@mail.gmail.com>
	<20100630023718.GU2138@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter mailing list <netfilter@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53518 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623Ab0F3JYd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 05:24:33 -0400
In-Reply-To: <20100630023718.GU2138@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Let me try and understand this.
>
> R is routing between 192.168.1.0/24 and 10.232.18.0/24.
> As A is on the 192.168.1.0/24 side of R.
> But to give A an 10.232.18.0/24 address (dynamically)?
>
> Why?
>

=46or some clients , R should act as a mere bridge , Not a router .


On Wed, Jun 30, 2010 at 8:07 AM, Simon Horman <horms@verge.net.au> wrot=
e:
> On Mon, Jun 28, 2010 at 03:43:46PM +0530, ratheesh k wrote:
>> Hi,
>>
>> =A0 A -------> R ------->S
>>
>> I have a linux machine A is connected to Linux machine R . Machine R
>> is having two network interfaces and acting as a router .
>> It has a dhcp server running =A0. It will assign ip in 192.168.1.0/2=
4
>> subnet to all machine connected on lan side ( A is connected also in
>> lan side ) . Wan side of R is connected to HTTP server S . There is
>> also a DHCP server running on S to assign ip in 10.232.18.0/24 subne=
t
>> . =A0Is there any way , in which NAT should be bypassed to get ip fr=
om
>> DHCP server running =A0on S . My question is : How can A will get =A0=
an ip
>> from 10.232.18.0/24 pool ip .?
>> ebtables is an option ? How can we make it ?
>> Is there any other optimal way ?
>
> Let me try and understand this.
>
> R is routing between 192.168.1.0/24 and 10.232.18.0/24.
> As A is on the 192.168.1.0/24 side of R.
> But to give A an 10.232.18.0/24 address (dynamically)?
>
> Why?
>
>
