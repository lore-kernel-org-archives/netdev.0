From: David Miller <davem@davemloft.net>
Subject: Re: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
Date: Mon, 31 Jan 2011 12:36:05 -0800 (PST)
Message-ID: <20110131.123605.226778418.davem@davemloft.net>
References: <20100530010219.GA20368@volta.aurel32.net>
	<8DD2590731AB5D4C9DBF71A877482A900118D29D0A@orsmsx509.amr.corp.intel.com>
	<20110131114558.GA28303@volta.aurel32.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: aurelien@aurel32.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754083Ab1AaUf3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 15:35:29 -0500
In-Reply-To: <20110131114558.GA28303@volta.aurel32.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Aurelien Jarno <aurelien@aurel32.net>
Date: Mon, 31 Jan 2011 12:45:58 +0100

>> On recent kernels, IAMT support does not work after the machine has=20
>> been powered-off. Even worse, it also goes into this state when I tr=
y
>> to reboot it.
>>=20
>> I have done a bisect and got this commit:
>>=20
>> |=A0commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
>> | Author: Bruce Allan <bruce.w.allan@intel.com>
>> | Date:   Fri Aug 14 14:35:33 2009 +0000
>> |=20
>> |     e1000e: WoL does not work on 82577/82578 with manageability en=
abled
>> |    =20
>> |     With manageability (Intel AMT) enabled via BIOS, PHY wakeup do=
es not get
>> |     configured on newer parts which use PHY wakeup vs. MAC wakeup =
which causes
>> |=A0    WoL to not work.  The driver should configure PHY wakeup whe=
ther or not
>> |     manageability is enabled.
>> |    =20
>> |     Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> |     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> |     Signed-off-by: David S. Miller <davem@davemloft.net>
>>=20
>> I have tried to revert it on recent kernels (2.6.34), and IAMT is th=
en
>> working as expected. My machine is using a Gigabyte EQ45M-S2 motherb=
oard
>> with an 82567LM-3 ethernet chip (8086:10de), that is a different mod=
el
>> than the one of the original problem.
>>=20
>> I do wonder if the changes in the patch should not only be done on s=
ome=20
>> chip models, and I will appreciate any help in fixing this issue.
>>=20
>=20
> Just a short mail to say this problem is still present in 2.6.38-rc2.
> The same solution still applies, that is reverting the above commit.
> Note that reverting the first hunk only is enough to get it working
> again.

Intel folks please look into this.
