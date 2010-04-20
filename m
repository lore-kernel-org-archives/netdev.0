From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:35:40 +0500
Message-ID: <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41306 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab0DTXfm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:35:42 -0400
Received: by bwz25 with SMTP id 25so7446643bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:35:40 -0700 (PDT)
In-Reply-To: <4BCE392F.60104@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have 40,000 out-going connections to myself..basically I'm
> acting as both client and server. =C2=A0So, I'd expect you to be

What is yours

sysctl -a | grep local_port_range

?


>
> Be sure to use lots of processes so you don't end up with
> a poll loop with 80,000 fd entries. =C2=A0I found that 10k sockets
> per process was a good upper limit..but it's not a hard
> upper limit.

sure -- it's a next step :)

>
> And be sure to do the bind logic correctly as Eric pointed out in an
> earlier email.
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =C2=A0http://www.candelatech.com
>



--=20
Gaspar Chilingarov
