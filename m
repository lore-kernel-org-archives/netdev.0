From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Fri, 17 Oct 2008 15:36:03 +0200
Message-ID: <20081017133603.GA28600@elte.hu>
References: <20081015.163817.193700221.davem@davemloft.net> <20081017082138.GA23155@elte.hu> <48F87D3E.5020007@trash.net> <20081017120408.GA20030@elte.hu> <48F88660.7080204@netfilter.org> <48F89311.6090208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	benh@kernel.crashing.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:48596 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507AbYJQNgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 09:36:17 -0400
Content-Disposition: inline
In-Reply-To: <48F89311.6090208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Patrick McHardy <kaber@trash.net> wrote:

> Pablo Neira Ayuso wrote:
>> Ingo Molnar wrote:
>>> * Patrick McHardy <kaber@trash.net> wrote:
>>>
>>>>> net/netfilter/nf_conntrack_netlink.c:819: warning: =E2=80=98enum =
=20
>>>>> nf_nat_manip_type=E2=80=99 declared inside parameter list
>>>>> net/netfilter/nf_conntrack_netlink.c:819: warning: its scope is=20
>>>>> only this definition or declaration, which is probably not what=20
>>>>> you want
>>>>> net/netfilter/nf_conntrack_netlink.c:818: error: parameter 2 =20
>>>>> (=E2=80=98manip=E2=80=99) has incomplete type
>>>> Thanks Ingo. I just sent this patch to Benjamin Herrenschmidt
>>>> for testing.
>>>
>>> build still fails with the attached config.
>>
>> This should fix it. I have slightly tested it here with your config.
>>
>
> Applied, thanks Pablo.
>
> I'll look into cleaning up those conditional includes. Its getting=20
> more and more complicated to even build-test all the combinations.

yeah - very often build errors in rare .config scenarios are canaries=20
for structural problems.

(We had such a situation in the x86 code recently: we had those quirky=20
x86 subarchitectures, and they were a constant source of build errors=20
that no real user actually cared about - because there were no active=20
users left. We modularized them into the main platform and we havent ha=
d=20
a single build bug in them in the last couple of months.)

	Ingo
