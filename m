From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue devices
Date: Wed, 02 Sep 2009 18:50:24 +0200
Message-ID: <4A9EA250.2010209@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com> <20090902092351.11649796@nehalam> <4A9E9D8A.50406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	cl@linux-foundation.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60692 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbZIBQu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 12:50:29 -0400
In-Reply-To: <4A9E9D8A.50406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Stephen Hemminger wrote:
>> Even if the kernel keeps the value in something else for the API
>> QINDEX needs to be a fixed size unsigned type like u32.
>=20
> Just to avoid duplicate work - I'm currently trying to put a patch
> together that presents multiqueue qdiscs to userspace as regular
> child qdiscs of a dummy qdisc, which also contains the aggregated
> statistics. So far it actually looks pretty sane :)

Excellent !

I am cooking a patch to make vlan devices multiqueue aware
(ie having same tx_queue numbers than their real_dev)

