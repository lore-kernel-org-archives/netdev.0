From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [GIT] Networking
Date: Thu, 5 Aug 2010 19:04:39 -0700
Message-ID: <AANLkTinU4+tcm2O_BVBFkHSdnx7JEPtM4sw_s--qdUKC@mail.gmail.com>
References: <20100803.203814.59697285.davem@davemloft.net>
	<AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35944 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab0HFCEk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 22:04:40 -0400
In-Reply-To: <AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 12:06 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Aug 3, 2010 at 8:38 PM, David Miller <davem@davemloft.net> wr=
ote:
>>
>> Another release, another merge window, another set of networking
>> changes to merge :-)
>
> Ok, merged. But you should double-check my merge resolution fixes,

  CC      drivers/net/ixgbe/ixgbe_main.o
drivers/net/ixgbe/ixgbe_main.c: In function =91ixgbe_select_queue=92:
drivers/net/ixgbe/ixgbe_main.c:6159: error: =91struct ixgbe_fcoe=92 has=
 no
member named =91up=92
drivers/net/ixgbe/ixgbe_main.c: In function =91ixgbe_xmit_frame=92:
drivers/net/ixgbe/ixgbe_main.c:6221: error: =91struct ixgbe_fcoe=92 has=
 no
member named =91up=92
make[1]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
make: *** [drivers/net/ixgbe/] Error 2

YH
