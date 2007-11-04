From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 04 Nov 2007 14:05:15 +0100
Message-ID: <472DC38B.5060208@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com> <200711041326.38380.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	acme@redhat.com, Jarek Poplawski <jarkao2@o2.pl>
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58175 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbXKDNFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 08:05:41 -0500
In-Reply-To: <200711041326.38380.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
>> But I suspect distributions kernels enable CONFIG_HOTPLUG_CPU so=20
>> num_possible_cpus() will be NR_CPUS.
>=20
> Nope, on x86 num_possible_cpus() is derived from BIOS tables these da=
ys.

Good to know, thank you Andi for this clarification.

