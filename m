From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Thu, 19 Oct 2006 07:13:59 +0200
Message-ID: <45370997.8000508@cosmosbay.com>
References: <200610181055.32102.dada1@cosmosbay.com>
 <20061018124202.GA31981@fogou.chygwyn.com>
 <200610181532.22979.dada1@cosmosbay.com>
 <20061018.205044.68042074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve@chygwyn.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:65237 "EHLO Smtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1423092AbWJSFTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 01:19:20 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7D003YRAJBRYR0@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 19 Oct 2006 07:13:59 +0200 (CEST)
In-reply-to: <20061018.205044.68042074.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 18 Oct 2006 15:32:22 +0200
>=20
>> OK then. Even on a distro kernel (allyesconfig), size(flow) would
>> shrink by 20 bytes.
>=20
> For the time being, why don't we just kill off the unused dnports
> bits entirely.
>=20
> Once the support code to use those bits is written, we can
> investigate intelligent ways to pack them back into struct
> flow, ok?
>=20
>=20

OK I will prepare a patch if Steve doesnt beat me :)

Eric

