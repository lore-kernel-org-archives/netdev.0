From: Andreas Schwab <schwab@suse.de>
Subject: Re: Bad UDP checksum with 82540EM
Date: Sun, 08 Feb 2004 14:09:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <jeznbtg1kf.fsf@sykes.suse.de>
References: <OFE5352D34.67E10D98-ON87256E33.00725857-86256E33.0076C481@us.ibm.com>
	<je3c9mv7ea.fsf@sykes.suse.de> <20040208074643.482ab4c7.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: jonmason@us.ibm.com, cramerj@intel.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040208074643.482ab4c7.ak@suse.de> (Andi Kleen's message of
 "Sun, 8 Feb 2004 07:46:43 +0100")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> writes:

> On Sat, 07 Feb 2004 23:42:21 +0100
> Andreas Schwab <schwab@suse.de> wrote:
>
>> Jon D Mason <jonmason@us.ibm.com> writes:
>>=20
>> > This probably isn't helpful, but it sounds like a hardware error.  I=
s the=20
>> > error occurring on multiple/all HP adapters, or only one?=20
>>=20
>> I've also seen it with a HP branded BCM5701 on IA64, but also with a
>> Broadcom BCM5702 on AMD64 (both using the tg3 driver).  It seems like
>> broken UDP checksumming is rather common. :-(
>
> It could be still a software bug.  When hardware checksumming is availa=
ble
> the UDP packets use a slightly different path through the stack.
>
> Could you perhaps test if the problem occurs in a 32bit box with the=20
> same NIC ? Maybe it is some 64bit problem somewhere in software.

Just tested with a "3Com 3C996B-T 1000Base-T" (BCM5701 based, with tg3
driver) on an Athlon.  It shows the same bug, and disabling HW
checksumming on tx fixes it.  So it doesn't look like a 64bit issue.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
