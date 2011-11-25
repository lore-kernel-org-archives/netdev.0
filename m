From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Fri, 25 Nov 2011 17:36:56 +0100
Message-ID: <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42465 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab1KYQhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 11:37:00 -0500
Received: by vcbfk14 with SMTP id fk14so2189115vcb.19
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 08:36:59 -0800 (PST)
In-Reply-To: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 14:33 +0100, Esztermann, Ansgar a =C3=
=A9crit :
> [originally posted to lkml]
> Hello list,
>=20
> is there some documentation available on TCP fast retransmit? There
> seem to be quite a lot of descriptions -- from informal to scholarly
> papers -- on the various algorithms available to calculate the proper
> size of the congestion window, but I have been unable so far to find
> out *when* a fast retransmit is triggered. RFC 2581 states the third
> dupACK "should" do it, and this seems to be quoted fairly often.
> However, I can easily produce connections that fail to perform fast
> retransmit even after 5 dupACKs. Some people mention Linux uses a
> different (presumable more sophisticated) algorithm to trigger fast
> retransmits, but no-one seems to elaborate.

Could you send a sample pcap of such problem, but please include full
tcp sesssion, from the first SYN packet, up to packets following
restransmits.

A diff of "netstat -s" taken before your session and after your session
on receiver would help too, if receiver is not a loaded machine of
course.

Also, what version of linux kernel are you using in receiver ?
