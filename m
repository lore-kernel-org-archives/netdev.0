From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: Networking
Date: Fri, 17 Oct 2008 15:28:49 +0200
Message-ID: <48F89311.6090208@trash.net>
References: <20081015.163817.193700221.davem@davemloft.net> <20081017082138.GA23155@elte.hu> <48F87D3E.5020007@trash.net> <20081017120408.GA20030@elte.hu> <48F88660.7080204@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	benh@kernel.crashing.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65056 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbYJQN24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 09:28:56 -0400
In-Reply-To: <48F88660.7080204@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Ingo Molnar wrote:
>> * Patrick McHardy <kaber@trash.net> wrote:
>>
>>>> net/netfilter/nf_conntrack_netlink.c:819: warning: =E2=80=98enum=20
>>>> nf_nat_manip_type=E2=80=99 declared inside parameter list
>>>> net/netfilter/nf_conntrack_netlink.c:819: warning: its scope is on=
ly=20
>>>> this definition or declaration, which is probably not what you wan=
t
>>>> net/netfilter/nf_conntrack_netlink.c:818: error: parameter 2=20
>>>> (=E2=80=98manip=E2=80=99) has incomplete type
>>> Thanks Ingo. I just sent this patch to Benjamin Herrenschmidt
>>> for testing.
>>
>> build still fails with the attached config.
>=20
> This should fix it. I have slightly tested it here with your config.
>

Applied, thanks Pablo.

I'll look into cleaning up those conditional includes. Its getting
more and more complicated to even build-test all the combinations.

