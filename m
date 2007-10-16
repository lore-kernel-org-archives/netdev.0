From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 13:05:40 +0200
Message-ID: <47149B04.30607@balabit.hu>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>	 <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu> <1192531516.4480.33.camel@localhost>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:55200 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757395AbXJPLFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 07:05:46 -0400
In-Reply-To: <1192531516.4480.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal =EDrta:
> On Tue, 2007-16-10 at 11:03 +0200, Laszlo Attila Toth wrote:
>> Interfaces can be grouped and each group has an unique positive inte=
ger ID.
>> It can be set via ip link.
>=20
> Feature request: Can you also implement a get operation. Perhaps
> something that returns from the kernel a list of ifindices when one
> passes a group to it?

That sounds great but for what whould you like to use? It may help me=20
for the implementation. Currently it is not available since the the=20
net_device structure holds the group id and for this get operation an=20
iteration (of net_devices) may be necessary...
>=20
> BTW, does it make sense to have one interface in multiple groups?

We didn't want to use multiple groups in favour of masked group ids.=20
What kind of usage needs other implementation?

--
Attila
