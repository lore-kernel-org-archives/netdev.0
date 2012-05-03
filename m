From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 still badly broken
Date: Thu, 3 May 2012 08:23:52 -0700
Message-ID: <20120503082352.771acab3@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
	<4FA14EC6.6050207@linuxsystems.it>
	<20120502115618.04ab8ff9@s6510.linuxnetplumber.net>
	<4FA2527A.6020808@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37313 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756170Ab2ECPXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 11:23:55 -0400
In-Reply-To: <4FA2527A.6020808@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 May 2012 11:40:10 +0200
Niccol=F2 Belli <darkbasic@linuxsystems.it> wrote:

> Il 02/05/2012 20:56, Stephen Hemminger ha scritto:
> > It could be that your switch doesn't do autonegotiation or flow
> > control. You are getting receive fifo overflow errors.
>=20
> I don't have this problem with other NICs. Also transfer rate is very=
=20
> low (even 2 MB/s sometimes) while I get ~110MB/s with other NICs (and=
=20
> the same switch of course).
>=20
> Niccol=F2

The receiver on some versions of the chip can't keep up with full speed
of 1G bit/sec. The receive  FIFO has hardware issues, and since I don't
work for Marvell, working around the problem is guesswork. Without exac=
t
information all that can be done is have a timeout and blunt force rese=
t
logic. The vendor driver sk98lin has the same brute force logic, but ma=
y
just not print the message.
