From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 09 Feb 2015 14:33:32 +0100
Message-ID: <8761bbqker.fsf@nemi.mork.no>
References: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
	<87a90nqp45.fsf@nemi.mork.no>
	<CAKfDRXhW-izhes0qq2qJA0ojm37Eg=dybYSdzo8u-VzhT15EGw@mail.gmail.com>
	<CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Aleksander Morgado <aleksander@aleksander.es>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49514 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759438AbbBINdp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 08:33:45 -0500
In-Reply-To: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	(Kristian Evensen's message of "Mon, 9 Feb 2015 13:26:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristian Evensen <kristian.evensen@gmail.com> writes:
> On Mon, Feb 9, 2015 at 12:55 PM, Kristian Evensen
> <kristian.evensen@gmail.com> wrote:
>> Hi,
>>
>> On Mon, Feb 9, 2015 at 12:51 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>>> Just to be sure: You do have a configuration where interfaces #10 a=
nd
>>> #11 are visible, but none of them respond to any QMI at all?  Not e=
ven
>>> CTL SYNC?  Could you get a minimal usbmon trace of that?
>
> Here is a minial usbmon where I send SYNC to interface 10. After I
> made the trace, I tried interface 8 (to make sure that there was
> nothing wrong with modem) and it worked fine. ModemManager or any
> similar tool is not running.

Thanks.

> The firmware is SWI9X15C_05.05.02.00 r19147 carmd-fwbuild1 2013/11/15=
 13:54:28

That is pretty old relative to this hardware. First commercial release?
I don't really want to push you to do an upgrade, but it would sure be
nice to have this test repeated on a recent firmware version.  Not that
I can spot anything particularily promising in the release notes.

Did you have one of these 9x15 modems, Aleksander?  Did you ever verify
whether the additional QMI interface(s) worked?

I did find our previous discussions about these two RMNET1 and RMNET2
functions, e.g:
http://lists.freedesktop.org/archives/libqmi-devel/2014-July/000875.htm=
l
and it seems to indicate that both work as long as you configure them
for 802.3 framing. But that could just be an information feedback
loop...=20


> -Kristian
> ffff8800cbbad240 1429569304 S Ii:3:050:7 -115:256 10 <
> ffff8800cbbadb40 1429569566 S Co:3:050:0 s 21 00 0000 000a 000c 12 =3D=
 010b0000 00000001 27000000
> ffff8800cbbadb40 1429570337 C Co:3:050:0 0 12 >
> ffff8800cbbad240 1434576966 C Ii:3:050:7 -2:256 0
> ffff8800cbbad240 1434577061 S Ii:3:050:7 -115:256 10 <
> ffff8800cbbadb40 1434577154 S Co:3:050:0 s 21 00 0000 000a 000c 12 =3D=
 010b0000 00000001 27000000
> ffff8800cbbadb40 1434577968 C Co:3:050:0 0 12 >
> ffff8800cbbad240 1439584564 C Ii:3:050:7 -2:256 0
> ffff8800cbbad240 1439584687 S Ii:3:050:7 -115:256 10 <
> ffff8800cbbadb40 1439584829 S Co:3:050:0 s 21 00 0000 000a 000c 12 =3D=
 010b0000 00000001 27000000
> ffff8800cbbadb40 1439585699 C Co:3:050:0 0 12 >
> ffff8800cbbad240 1440477055 C Ii:3:050:7 -2:256 0




Hmm, it's been a long time since I've looked at one of these so I might
be wrong, but I must admit that it looks pretty dead.  I assume the
ENOENT Ii callback status indicates a timeout?



Bj=C3=B8rn
