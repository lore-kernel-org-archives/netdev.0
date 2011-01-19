From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Wed, 19 Jan 2011 21:12:31 +0100
Message-ID: <4D3745AF.5040808@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36303 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab1ASUMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 15:12:36 -0500
Received: by ywl5 with SMTP id 5so512549ywl.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 12:12:36 -0800 (PST)
In-Reply-To: <4D370DC7.6000500@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/01/2011 17:13, Oleg V. Ukhno a =C3=A9crit :
> On 01/18/2011 11:24 PM, Jay Vosburgh wrote:
[snip]
>> I haven't done much testing with this lately, but I suspect this
>> behavior hasn't really changed. Raising the tcp_reordering sysctl va=
lue
>> can mitigate this somewhat (by making TCP more tolerant of this), bu=
t
>> that doesn't help non-TCP protocols.
>>
>> Barring evidence to the contrary, I presume that Oleg's system
>> delivers out of order at the receiver. That's not automatically a
>> reason to reject it, but this entire proposal is sufficiently comple=
x to
>> configure that very explicit documentation will be necessary.
>>
>> -J
>>
>> ---
>> -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>
>
> Jay,
[snip]
>
> What is your opinion on my idea with patch?
>
> I will come back with results for VLAN tunneling case, if this is
> necessary (Nicolas, shall I do that test - I think it will show simil=
ar
> results for performance?)

If you have time for that, then yes, please, do the same test using bal=
ance-rr+vlan to segregate=20
path. With those results, we whould have the opportunity to enhance the=
 documentation with some well=20
tested cases of TCP load balancing on a LAN, not limited to 802.3ad aut=
omatic setup. Both setups=20
make sense, and assuming the results would be similar is probably true,=
 but not reliable enough to=20
assert it into the documentation.

Thanks,

	Nicolas.
