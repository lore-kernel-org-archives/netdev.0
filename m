From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [Bonding-devel] bonding inside a bridge does not work when using
 arp monitoring
Date: Sat, 26 Mar 2011 16:42:54 +0100
Message-ID: <AANLkTimkVqHaU=Ye96xK4Zs7XyzcL3Xgh5ouz5m2KXur@mail.gmail.com>
References: <1300302933.1462.5.camel@bordalnx> <4D8121EF.3030200@free.fr>
 <1300914794.32252.68.camel@bordalnx> <4D8DDA06.4040704@gmail.com> <20110326140115.GA2882@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Leonardo Borda <leonardo.borda@canonical.com>,
	=?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>,
	Bridge <bridge@lists.linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62752 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab1CZPnP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 11:43:15 -0400
Received: by qwk3 with SMTP id 3so1136380qwk.19
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2011 08:43:14 -0700 (PDT)
In-Reply-To: <20110326140115.GA2882@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/26 Jiri Pirko <jpirko@redhat.com>:
> Sat, Mar 26, 2011 at 01:20:22PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>>Le 23/03/2011 22:13, Leonardo Borda a =E9crit :
>>>Thank you for answering my question.
>>>Actually this is what I want to achieve:
>>>
>>>eth0----+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 +----bond0.100----br0-100---{+=
virtual machines
>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 |
>>> =A0 =A0 =A0 =A0 =A0 +----bond0----+----br0---(LAN)
>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 |
>>>eth1----+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 +----bond0.200----br0-200---{+=
virtual machines
>>
>>Hi Leonardo,
>>
>>I'm not sure recent kernels allow for a given interface to be a port
>>for a bridge and the base interface for vlan interfaces at the same
>>time. This might be particularly true for 2.6.38 or 2.6.38+, because
>>of the new rx_handler usage.
>
> This topology is not legit and should/will be prohibited.
>
> Only consider that you have + br0.100 device on top of br0. Where sho=
uld
> the packet go?
>
> I suggest to consider topology change.

It should be possible to have bridge for untagged (or 802.1p only)
packets independent of 802.1q tagged packets. I wonder if tag 0
devices should be expanded to have a flag that will enable handling
untagged packets by it.

Best Regards,
Micha=B3 Miros=B3aw
