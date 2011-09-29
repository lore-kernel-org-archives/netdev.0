From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Problem with ARP-replies on Kernels 2.6 (possibly 3.0, but not
 2.4!)
Date: Thu, 29 Sep 2011 23:43:02 +0200
Message-ID: <4E84E666.5080003@gmail.com>
References: <4E835E35.3030503@gmx.at> <4E837E98.4080608@gmail.com> <4E8390E4.7080104@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: skandranon <skandranon@gmx.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42555 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab1I2Vmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 17:42:53 -0400
Received: by wwf22 with SMTP id 22so1713649wwf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 14:42:52 -0700 (PDT)
In-Reply-To: <4E8390E4.7080104@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/09/2011 23:25, skandranon a =E9crit :

>>> So: Is this a bug or a feature?
>>
>> It is a feature.
>>
>> You should have a look at the file Documentation/networking/ip-sysct=
l in the kernel source tree,
>> in particular the entry about arp_ignore.
>>
>> Nicolas.

> Many thanks for your quick reply and the pointer to that document.

Please, keep netdev in copy.

> Seems this feature has been there a long time already, but this has b=
een the first time in all of
> the 15 years or so I'm working with Linux that It's bitten my ass.
>
> May I ask you for an additional pointer explaining in layman's terms =
what the use cases for values 2
> and 3 would be? - I plain don't understand.

2 seems obvious and is one more level of strictness. If the ARP seems t=
o come from a different=20
subnet, ignore it, even if it enters the host on the "right" interface.

I don't know for 3.

> And maybe even an explanation what the initial reasoning might have b=
een to select the approach of
> assigning IP addresses to the host instead of an interface?

I think it is expected to enhance connectivity, by being liberal at wha=
t the host accept, which is=20
the base principle of interoperability : Be liberal in what you accept,=
 and conservative in what you=20
send [Jon Postel]. Others may explain this with more history in mind.

> The mailing list archive mentioned in e.g. "Understanding Linux Netwo=
rk Internals" I found after
> having your hint as a starting point doesn't seem to contain this dis=
cussion, which has obviously
> been old even back in 2003.
> And how come that the 2.4.21 kernel did behave differently? The basic=
s seem to be the same?

Unfortunately, I'm not an archaeologist, so I'm totally unable to answe=
r about 2.4.21. Maybe someone=20
else in the list will be.

	Nicolas.
