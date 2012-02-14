From: Eugenia Emantayev <eugenia@mellanox.com>
Subject: RE: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Tue, 14 Feb 2012 20:00:05 +0000
Message-ID: <74A0102445410646AFACC089FD94803A5CEEACB5@MTLDAG02.mtl.com>
References: <4F3A8DB5.3020703@mellanox.co.il>
 <20120214.143023.281327914225614215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:39710 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757123Ab2BNUCE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 15:02:04 -0500
In-Reply-To: <20120214.143023.281327914225614215.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

Some of the patches fix very harmful memory leaks and corruptions.
Could you please apply only these 3 specific patches to the net tree?
They are
	[PATCH net 1/7] mlx4_core: fix buffer overrun
	[PATCH net 2/7] mlx4: fix QP tree trashing
	[PATCH net 7/7] mlx4: add unicast steering entries to resource_tracker



Best regards,
Jenny (Eugenia) Emantayev

SW Engineer
Networking group
Mellanox Technologies LTD 
Tel: +972-74-7237250
Mob: +972-54-7370475 
Fax: +972-4-959-3245 
P.O. Box 586 Yokneam 20692 ISRAEL



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, February 14, 2012 21:31
To: Yevgeny Petrilin
Cc: netdev@vger.kernel.org; Eugenia Emantayev
Subject: Re: [PATCH net 0/7] mlx4: Bug fixes and cleanups

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 14 Feb 2012 18:37:09 +0200

> This is a series of fixes and cleanups for mlx4_core driver,
> Most of them related tracking of VF resources.
> The fixes solve issues caused when the VF don't close gracefully (FLR for example)

All applied to net-next, such cleanups are absolutely not appropriate
for the net tree.
