From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Re: [PATCH v2] lxt PHY: Support for the buggy LXT973 rev A2
Date: Sat, 22 Sep 2012 18:21:38 +0200
Message-ID: <505DE592.8060103@c-s.fr>
References: <201209101545.q8AFjn7u021483@localhost.localdomain> <20120910181747.GA5960@lutz.bln.innominate.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lutz Jaenicke <ljaenicke@innominate.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120910181747.GA5960@lutz.bln.innominate.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 10/09/2012 20:17, Lutz Jaenicke a =E9crit :
> On Mon, Sep 10, 2012 at 05:45:49PM +0200, Christophe Leroy wrote:
>> This patch adds proper handling of the buggy revision A2 of LXT973 p=
hy, adding
>> precautions linked to ERRATA Item 4:
>>
>> Item 4: MDIO Interface and Repeated Polling
>> Problem: Repeated polling of odd-numbered registers via the MDIO int=
erface
>> 	randomly returns the contents of the previous even register.
>> Implication: Managed applications may not obtain the correct registe=
r contents
>> 	when a particular register is monitored for device status.
>> Workaround: None.
>> Status: This erratum has been previously fixed (in rev A3)
> Hmm. Were did you get the hardware from? We have been using LXT973 in
> our products and the A2 was replaced by A3 in 2003.
>
> Best regards,
> 	Lutz
They are custom boards that my company manufactures. Most boards=20
manufactured before 2006 or 2007 have this buggy chip.

Regards
Christophe
