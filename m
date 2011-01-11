From: =?UTF-8?B?SmFyZWsgS2FtacWEc2tp?= <jarek@vilo.eu.org>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Tue, 11 Jan 2011 08:29:19 +0100
Message-ID: <4D2C06CF.4090507@vilo.eu.org>
References: <20110110131439.GA663@rocket.almost.secure.la> <1294724952.3235.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 609538@bugs.debian.org, Hayes Wang <hayeswang@realtek.com>,
	romieu@fr.zoreil.com, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vilo.eu.org ([80.52.229.66]:36892 "EHLO vilo.eu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab1AKHjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 02:39:14 -0500
In-Reply-To: <1294724952.3235.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 11.01.2011 06:49, Ben Hutchings pisze:
> On Mon, 2011-01-10 at 14:14 +0100, Jarek Kami=C5=84ski wrote:
>> Package: linux-2.6
>> Version: 2.6.37-1~experimental.1

>> 2.6.37 introduces regression in r8169. During every resume I get ~20
>> seconds delay:
>> Jan 10 13:57:15 rocket kernel: [36458.257780] ata1.00: configured fo=
r UDMA/100
>> Jan 10 13:57:15 rocket kernel: [36517.738421] r8169 0000:13:00.0: et=
h0: unable to apply firmware patch
>> Jan 10 13:57:15 rocket kernel: [36517.739859] PM: resume of devices =
complete after 61177.644 msecs
>> Jan 10 13:57:15 rocket kernel: [36517.740258] PM: Finishing wakeup.
>> Jan 10 13:57:15 rocket kernel: [36517.740259] Restarting tasks ... d=
one.
>>
>> Bisecting leads to commit bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0
>> (r8169: remove the firmware of RTL8111D.).

>> Either r8169 tries to load firmware too early, or it should keep it
>> loaded in memory for use during resume.
>=20
> It should.  But an earlier version of this patch was also in Debian's
> 2.6.36 so it would have had the same problem.

The last 2.6.36 I've tried was 2.6.36-1~experimental.1, I've then
passsed and returned to 2.6.32 for unrelated problems. I think it wasn'=
t
affected, but I can re-check it and/or test later 2.6.36 versions if it
may help.

Sorry if my information was misleading.


--=20
pozdr(); // Jarek
