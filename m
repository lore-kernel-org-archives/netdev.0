From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 17:12:03 -0300
Message-ID: <5489FA93.1030104@free-electrons.com>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk> <20141211.151055.817876561546126576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46359 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758237AbaLKUNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:13:53 -0500
In-Reply-To: <20141211.151055.817876561546126576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2014 05:10 PM, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Thu, 11 Dec 2014 19:49:20 +0000
>=20
>> Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
>> all fragments with dma_map_single().  This fails when the driver is
>> used in an environment with highmem.
>=20
> This change looks really buggy to me.
>=20
> Unfortunately, all the changes he subsequently makes for software TSO
> support depend upon this :-/
>=20
> The change is definitely wrong.
>=20

Got it. I'll take a closer look and will try to think a fix for this.

--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
