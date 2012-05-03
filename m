From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 still badly broken
Date: Thu, 3 May 2012 14:25:17 -0700
Message-ID: <20120503142517.310ea84c@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
	<4FA14EC6.6050207@linuxsystems.it>
	<20120502115618.04ab8ff9@s6510.linuxnetplumber.net>
	<4FA2527A.6020808@linuxsystems.it>
	<20120503082352.771acab3@nehalam.linuxnetplumber.net>
	<4FA2DE52.306@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43698 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549Ab2ECVZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 17:25:30 -0400
In-Reply-To: <4FA2DE52.306@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 May 2012 21:36:50 +0200
Niccol=F2 Belli <darkbasic@linuxsystems.it> wrote:

> Il 03/05/2012 17:23, Stephen Hemminger ha scritto:
> > The receiver on some versions of the chip can't keep up with full s=
peed
> > of 1G bit/sec. The receive  FIFO has hardware issues, and since I d=
on't
> > work for Marvell, working around the problem is guesswork.
>=20
> Just one question: if that is true why don't I have any problem with =
a=20
> point to point gigabit link? I did transfer 3GB from ram to ram (ramf=
s)=20
> at 100+MB/s without any issue in a point to point setup, as soon as I=
=20
> attach it to the switch I have problems (very low transfer rate and t=
ons=20
> of rx errors).

I don't know but the PHY interaction is different with auto-crossover.
