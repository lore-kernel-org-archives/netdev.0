From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:20:55 +0500
Message-ID: <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50026 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab0DTXU4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:20:56 -0400
Received: by bwz25 with SMTP id 25so7437033bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:20:55 -0700 (PDT)
In-Reply-To: <4BCE33B9.8050101@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Opening that amount of incoming connections in not a problem at all.

I'm speaking of outgoing connections.

What kind of hack do you have on your kernel?

Thanks in advance,
Gaspar

2010/4/21 Ben Greear <greearb@candelatech.com>:
> On 04/20/2010 03:17 PM, Gaspar Chilingarov wrote:
>
>> I would be grateful for hints where to look in the source -- may be =
I
>> can produce some working patches for it.
>
> I've opened 40,000 connections to/from my machine (over external inte=
rfaces)
> on a slightly hacked .31 kernel. =C2=A0This is 80,000 sockets total. =
=C2=A0I bind
> to local IP and port range, as well as SO_BINDTODEVICE.
>
> I'm using a 64-bit system with 12GB of RAM, quad-core i7 3.3Ghz, etc.
>
> It takes a lot of RAM to do this but you can probably use less RAM in
> user-space
> than I am. =C2=A0Be sure to set your socket buffer sizes small.
>
> Thanks,
> Ben
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =C2=A0http://www.candelatech.com
>



--=20
Gaspar Chilingarov
