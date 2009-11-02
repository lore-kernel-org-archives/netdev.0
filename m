From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 15:38:24 -0500
Message-ID: <4AEF4340.9020608@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AEDDF33.9030205@gmail.com> <4AEECFA8.1080306@gmail.com> <alpine.DEB.2.00.0911021448280.19761@wel-95.cs.helsinki.fi> <4AEF0603.7060502@gmail.com> <4AEF1106.40403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:38414 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756259AbZKBUiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 15:38:24 -0500
Received: by fg-out-1718.google.com with SMTP id 16so141995fgg.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 12:38:28 -0800 (PST)
In-Reply-To: <4AEF1106.40403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> William Allen Simpson a =E9crit :
>=20
>> It will be, when we have running code, as I'm loath to publish until=
 I'm
>> certain it *can* be implemented.
>=20
> This is why RFC is better before coding. To avoid wasting time on exp=
eriments
> that have a fatal flaw. Once included in an official kernel, we wont =
be able
> to change some parameters very easily (think about 253 constant you u=
se)
>=20
We are talking at cross purposes.  IEEE had/has a tendency to publish
without running code.  CTIA/TIA/EIA has interim standards without runni=
ng
code, and had/has rules against even speaking about implementations.  O=
nly
IETF expected/expects running code.  An RFC is rarely issued before cod=
ing.

http://www.iana.org/assignments/tcp-parameters/

253     N       RFC3692-style Experiment 1 (*)         [RFC4727]

When my code is done, I'll post the completed draft and ask IANA for a
non-experimental number.  That's the usual process.  My code shouldn't =
go
into an official release until we know that number.

PS. Rumor has it that Cisco shipped a release with 254 in it.  Let's no=
t
do that here.

PPS. Adam used 255, not a correct official experimental number.
