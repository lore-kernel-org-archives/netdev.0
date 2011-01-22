From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Sat, 22 Jan 2011 13:48:52 +0100
Message-ID: <4D3AD234.7080709@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41872 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab1AVMsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 07:48:55 -0500
Received: by wwa36 with SMTP id 36so2818512wwa.1
        for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 04:48:54 -0800 (PST)
In-Reply-To: <4D399062.3060004@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/01/2011 14:55, Oleg V. Ukhno a =C3=A9crit :
> On 01/19/2011 11:12 PM, Nicolas de Peslo=C3=BCan wrote:
>
>> If you have time for that, then yes, please, do the same test using
>> balance-rr+vlan to segregate path. With those results, we whould hav=
e
>> the opportunity to enhance the documentation with some well tested c=
ases
>> of TCP load balancing on a LAN, not limited to 802.3ad automatic set=
up.
>> Both setups make sense, and assuming the results would be similar is
>> probably true, but not reliable enough to assert it into the
>> documentation.
>>
>> Thanks,
>>
>> Nicolas.
>>
> Nicolas,
> I've ran similar tests for VLAN tunneling scenario. Results are
> identical, as I expected. The only significat difference is link fail=
ure
> handling. 802.3ad mode allows almost painless load reditribution,
> balance-rr causes packet loss.

Oleg,

Thanks for doing the tests.

What link failure mode did you use for those tests ? miimon or arp moni=
toring ?

	Nicolas.

