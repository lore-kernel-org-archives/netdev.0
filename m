From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 15:39:40 +0100
Message-ID: <CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
	<CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sowmini Varadhan <sowmini05@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:36310 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbCZOjm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:39:42 -0400
Received: by labe2 with SMTP id e2so47075821lab.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:39:40 -0700 (PDT)
In-Reply-To: <CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-26 15:29 GMT+01:00 Sowmini Varadhan <sowmini05@gmail.com>:
> On Thu, Mar 26, 2015 at 9:16 AM, Bj=C3=B8rnar Ness <bjornar.ness@gmai=
l.com> wrote:
>> Hello, hope this is the right place to ask.
>>
>> Does anyone know if there is work beeing done in natively supporting
>> IPv6 nexthops for IPv4?
>
> What problem are you trying to solve? Do you want to tunnel your
> ipv4 packet through IPv6? there are a number of tunneling mechanisms
> in linux for this.

No, no tunneling, just route the packet directly as-is to the ipv6 next=
hop

>> I know that "some" Linux switch software company is working on this,=
 but
>> I am afraid the functionality will be more of a "hack".
>>
>> The benefit of this is stateless configuration (rfc5549), using IPv6=
 link-local
>> neighbor address as IPv4 nexthop, beeing able to do for example:
>>
>> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp0
>
> Trying to understand what the desired behavior is, for the route
> above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want the dst=
-mac
> to be the mac address of e80::225:90ff:fed3:bfb4???

Absolutely, correct.

> how do you know that fe80::225:90ff:fed3:bfb4 supports ipv4
> forwarding on the receiving interface (and if it does, why didn't it
> advertise itself as an IPv4 router on that interface)?

Basically because you either added the route manually, or it was provid=
ed
by fe80::225:90ff:fed3:bfb4 itself via some routing protocol (MP-BGP)

This will be the same as any other route. How do you know it forwards t=
raffic..

In large routed setups, address management in general and lack of IPv4 =
addresses
can become a big hassle. Beeing able to get a ipv6 neighbor for a ipv4
route would
make this process a lot simpler.

--=20
Bj(/)rnar
