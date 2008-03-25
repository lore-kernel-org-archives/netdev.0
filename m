From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC PATCH net-2.6.26] [NET] NETNS: Omit net_device->nd_net without
 CONFIG_NET_NS.
Date: Tue, 25 Mar 2008 18:41:41 +0100
Message-ID: <47E93955.6070800@fr.ibm.com>
References: <20080325.231442.15922868.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:9586 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070AbYCYRm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 13:42:28 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2PHgR5m042298
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 17:42:27 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2PHgQwx1245344
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 18:42:26 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2PHgQD4012972
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 18:42:26 +0100
In-Reply-To: <20080325.231442.15922868.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Introduce per-net_device inlines: dev_net(), dev_net_set().
> Without CONFIG_NET_NS, no namespace other than &init_net exists.
> Let's explicitly define them to help compiler optimizations.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thank you very much - Arrigato Gozaimas
That helps a lot.

I will rework the next patchset to take it into account.

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>


