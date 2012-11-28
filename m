From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 09:21:52 +0100
Message-ID: <2194699.8nM4x1vIbh@cpaasch-mac>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com> <20121127.210611.1127622873924794001.davem@davemloft.net> <1354089566.21562.20.camel@shinybook.infradead.org>
Reply-To: Christoph Paasch <christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:47781 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab2K1IV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 03:21:56 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5159181eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 00:21:55 -0800 (PST)
In-Reply-To: <1354089566.21562.20.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 November 2012 07:59:26 David Woodhouse wrote:
> My 'strange justification' for reordering, albeit not entirely on
> purpose, is that a single ADSL line at 8Mb/s down, 448Kb/s up is less
> bandwidth than I had to my dorm room 16 years ago. So I bond two of
> them, and naturally expect a certain amount of reordering.

You might want to have a look at MultiPath TCP [1], which allows the us=
e of=20
multiple interfaces for a single TCP connection. It is somehow similar =
to=20
SCTP-CMT, with the difference that MPTCP is able to pass by today's fir=
ewalls=20
and NATs and does not require any modifications to the applications.


E.g., you could install MPTCP on your end host and set up an HTTP-proxy=
 on a=20
public web hoster to terminate your MPTCP session -- as servers don't (=
yet)=20
support MPTCP, you will have to terminate the MPTCP session somewhere.


Cheers,
Christoph

[1] http://multipath-tcp.org

--=20
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=E9 Catholique de Louvain
--
