From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Sat, 03 May 2008 13:03:59 +0100
Message-ID: <481C54AF.1050109@andyfurniss.entadsl.com>
References: <4815BCDF.6070704@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi> <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi> <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi> <48199342.9010406@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:57090 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756126AbYECMDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 May 2008 08:03:54 -0400
In-Reply-To: <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:

> I suppose it flooded the log so that head of the log got lost already=
=20
> before userspace could consume it... (I think it's ringbuffer or some=
thing=20
> though I'm not sure), it might be wise to enlarge it (I think it's=20
> controlled through CONFIG_LOG_BUF_SHIFT).
>=20
> Since I've not yet found any other path that could lead to it except =
the=20
> yesterday's false-positive, getting the write queue state more accura=
tely=20
> captured by the debug patch on the very first occassion might help. H=
ere's=20
> less spammy version of the debug patch (I added one printout as well =
to=20
> get more usefulness to transitional state reported).
>=20

OK, increased CONFIG_LOG_BUF_SHIFT from 14 to 18 and reversed old /=20
applied new patch.

Andy.

