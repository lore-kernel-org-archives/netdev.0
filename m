From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 09:55:29 +0100
Message-ID: <4BB45F81.1070801@katalix.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>	 <20100330161746.9628.40723.stgit@bert.katalix.com>	 <20100330092914.4f3e9ed3@nehalam>	<4BB2FD0D.1080105@katalix.com>	 <20100331160811.16351eb7@s6510>  <4BB4490F.8090406@katalix.com> <1270107034.2229.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49107 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484Ab0DAIzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 04:55:41 -0400
In-Reply-To: <1270107034.2229.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 01 avril 2010 =E0 08:19 +0100, James Chapman a =E9crit :
>=20
>> There might be thousands of L2TP sessions in some setups. Populating
>> sysfs with a link for each of those sessions isn't practical. The
>> existing /proc file dumps its info as a single text file for this
>> reason. I'd also like to provide the device name in the session netl=
ink
>> message, which is the interface used by l2tp userspace, so I need a
>> kernel API to retrieve the device name from ppp.
>>
>> I like the suggestion of using debugfs for access to driver debug in=
fo
>> though. I propose leaving the /proc file for L2TPv2 only, removing t=
he
>> L2TPv3 data that I added to the proc file in this patch series, to
>> retain compatibility with the existing driver. This would show only
>> L2TPv2 sessions and tunnels. For new driver functionality (L2TPv3 et=
c),
>> use debugfs. The debugfs files would dump lists in a similar form to=
 the
>> current code, listing all tunnels (L2TPv2 and L2TPv3) in a single fi=
le.
>> Using debugfs gives more flexibility for adding additional info late=
r,
>> as required. How does that sound?
>>
>=20
> debugfs ? I dont get it, sorry.
>=20
> Why not using netlink, as most iproute2 utilities do ?

I am using netlink. This is only for providing extra (convenience) debu=
g
info from the kernel drivers. It's something I can easily ask users to
do if they have a problem.


--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

