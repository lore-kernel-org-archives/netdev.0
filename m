From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT]: Networking
Date: Fri, 17 Oct 2008 14:23:48 +0200
Message-ID: <48F883D4.8050809@netfilter.org>
References: <20081015.163817.193700221.davem@davemloft.net> <20081017082138.GA23155@elte.hu> <48F87D3E.5020007@trash.net> <20081017120408.GA20030@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33871 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751843AbYJQMOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 08:14:09 -0400
In-Reply-To: <20081017120408.GA20030@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Patrick McHardy <kaber@trash.net> wrote:
>=20
>>> net/netfilter/nf_conntrack_netlink.c:819: warning: =91enum nf_nat_m=
anip_type=92 declared inside parameter list
>>> net/netfilter/nf_conntrack_netlink.c:819: warning: its scope is onl=
y this definition or declaration, which is probably not what you want
>>> net/netfilter/nf_conntrack_netlink.c:818: error: parameter 2 (=91ma=
nip=92) has incomplete type
>> Thanks Ingo. I just sent this patch to Benjamin Herrenschmidt
>> for testing.
>=20
> build still fails with the attached config.

We have to wrap ctnetlink_parse_nat_setup with CONFIG_NF_NAT_NEEDED,=20
I'll send you a patch asap. Sorry for the breakage.

--=20
"Los honestos son inadaptados sociales" -- Les Luthiers
