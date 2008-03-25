From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC PATCH net-2.6.26 2/3] [NET] NETNS: Omit sock->sk_net without
 CONFIG_NET_NS.
Date: Tue, 25 Mar 2008 18:43:02 +0100
Message-ID: <47E939A6.2060507@fr.ibm.com>
References: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:61180 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbYCYRns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 13:43:48 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2PHhksr460474
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 17:43:46 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2PHhkpX2220046
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 18:43:46 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2PHhkxi009443
	for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 18:43:46 +0100
In-Reply-To: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Introduce per-sock inlines: sock_net(), sock_net_set().
> Without CONFIG_NET_NS, no namespace other than &init_net exists.
> Let's explicitly define them to help compiler optimizations.

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
