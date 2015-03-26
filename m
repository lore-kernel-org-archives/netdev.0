From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 10:29:14 -0400
Message-ID: <CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34091 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbbCZO3P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:29:15 -0400
Received: by wgs2 with SMTP id 2so66487914wgs.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:29:14 -0700 (PDT)
In-Reply-To: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 9:16 AM, Bj=C3=B8rnar Ness <bjornar.ness@gmail.=
com> wrote:
> Hello, hope this is the right place to ask.
>
> Does anyone know if there is work beeing done in natively supporting
> IPv6 nexthops for IPv4?

What problem are you trying to solve? Do you want to tunnel your
ipv4 packet through IPv6? there are a number of tunneling mechanisms
in linux for this.


>
> I know that "some" Linux switch software company is working on this, =
but
> I am afraid the functionality will be more of a "hack".
>
> The benefit of this is stateless configuration (rfc5549), using IPv6 =
link-local
> neighbor address as IPv4 nexthop, beeing able to do for example:
>
> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp0

Trying to understand what the desired behavior is, for the route
above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want the dst-m=
ac
to be the mac address of e80::225:90ff:fed3:bfb4???
how do you know that fe80::225:90ff:fed3:bfb4 supports ipv4
forwarding on the receiving interface (and if it does, why didn't it
advertise itself as an IPv4 router on that interface)?

>
> This is somehow possible now by exploiting static arp entries and
> "unused" IPv4 addresses for nexthop, but is far from ideal.
>
> Hope someone will be able to provide some insight on what is planned
> in this area, and weather this direct functionality will ever make it
> into the kernel.
>
