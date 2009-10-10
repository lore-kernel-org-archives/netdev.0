From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [7/8,RFC] CAIF Protocol Stack
Date: Sat, 10 Oct 2009 18:09:55 +0200
Message-ID: <4AD0B1D3.2060208@babic.homelinux.org>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA1D31.6000008@babic.homelinux.org> <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se> <4ACDF12A.6030906@babic.homelinux.org> <61D8D34BB13CFE408D154529C120E07902ED7054@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout31.attiva.biz ([88.44.63.37]:23770 "EHLO
	smtpout31.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbZJJQQF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 12:16:05 -0400
In-Reply-To: <61D8D34BB13CFE408D154529C120E07902ED7054@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sjur Br=E6ndeland wrote:
> Hi Stefano.

Hi Sjur,

>> Meanwhile, it seems some bytes are sent now to the physical interfac=
e.
>>
>> <caif_chropen:797, TRACE> [caif_chropen:797] WAIT FOR CONNECT
>> RESPONSE <caif_chropen:820, TRACE> caif_open: connect timed out=20
>>
>> However, I get no connection, but probably this is another problem..=
=2E.
>>
>=20
> Do you have a (ST-)Ericsson modem talking CAIF connected?
> The correct behavior is to wait for the CONNECT_RESPONSE, and time ou=
t.

Surely I have the best way to test a CAIF connection, even if I am not
aware of it ;).
I connected my target with an Ericsson Test Device "B26", that seems
suitable for this kind of test. I know very little about it, I can only
turn it on.
It has a debug port and I can see the debug output of the CAIF
connection in unformatted ASCII text (however, minicom formats this
output when I log the traces).

These strings should identify this device:

(00:01.894746) BuildInfo: Label: <CRH109940_R2F015> Variant:
<BRIDGE_CCPU_ACC_B26>
(00:01.894746) BuildInfo: Generated: 2007-08-07 15:00 by EMWJBON
(00:01.901973) Product  : <Ericsson Mobile Platform> Version: 0000
(00:01.908459) HW Setup : NOT SPECIFIED (Id:0xc8) IRDA: 0033 BT: 0035
RS232: 004A
(00:01.914875) Vendor   : <Ericsson> PNP: ERI USB: 0BDB BT: 0000

However, I am now able to start successfully a CAIF connection and I ca=
n
see the AT commands I send on the debug output of the B26.
On my target, I can get:

<caif_chropen:853, TRACE> [caif_chropen:853] CONNECTED

I see you sent a newer patchset and I will repeat my test with it.

Stefano

--=20
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
=46ingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
