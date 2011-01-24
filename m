From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Mon, 24 Jan 2011 22:32:42 +0300
Message-ID: <4D3DD3DA.7060407@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru> <4D3AD234.7080709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mammoth.yandex.ru ([93.158.136.51]:49829 "EHLO
	mammoth.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1AXTeN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 14:34:13 -0500
In-Reply-To: <4D3AD234.7080709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2011 03:48 PM, Nicolas de Peslo=C3=BCan wrote:
> Le 21/01/2011 14:55, Oleg V. Ukhno a =C3=A9crit :
>> On 01/19/2011 11:12 PM, Nicolas de Peslo=C3=BCan wrote:

>>>
>> Nicolas,
>> I've ran similar tests for VLAN tunneling scenario. Results are
>> identical, as I expected. The only significat difference is link fai=
lure
>> handling. 802.3ad mode allows almost painless load reditribution,
>> balance-rr causes packet loss.
>
> Oleg,
>
> Thanks for doing the tests.
>
> What link failure mode did you use for those tests ? miimon or arp
> monitoring ?
>
> Nicolas.
>
>

Nicolas,
  as for tests:
  MII link monitoring kills the whole transfer, when in ARP mode=20
monitoring - it still works, but there is asymmetric load striping on=20
bond slaves(one slave is overloaded, two other - about 50-60% badwidnth=
=20
utilized.
Just as a summary - balance-rr behaves like patched 802.3ad when using=20
arp monitoring mode, but there is quite asymmetric load striping and=20
quite a monstrous configuration on switch and server sides.



--=20
Best regards,
Oleg Ukhno


