From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 05 Dec 2007 05:47:11 -0800 (PST)
Message-ID: <20071205.054711.186439758.davem@davemloft.net>
References: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
	<20071205.052034.251196808.davem@davemloft.net>
	<d0383f90712050541p5d8ffce6q8748d7c6b66ea9c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751865AbXLENrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:47:11 -0500
In-Reply-To: <d0383f90712050541p5d8ffce6q8748d7c6b66ea9c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Wed, 5 Dec 2007 15:41:37 +0200

> Hello,
> Sorry; I was not aware of it; I am sending here  the patch as an attachment.
> It is a typo correction in __xfrm4_bundle_create() in net/ipv4/xfrm4_policy.c;
>  it should be "Copy neighbour" instead "Copy neighbout"

__xfrm4_bundle_create() no longer exists in the networking
development tree:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git

Because Herbert Xu unified much of the IPSEC handling
paths over the past few weeks.
