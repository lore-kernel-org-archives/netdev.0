From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/14] net/mlx4_en: Optimizations to TX flow
Date: Sun, 05 Oct 2014 08:50:52 -0700
Message-ID: <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
	 <54312F50.2060608@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48519 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbaJEPuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 11:50:55 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so2046315pdi.10
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 08:50:55 -0700 (PDT)
In-Reply-To: <54312F50.2060608@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-10-05 at 14:45 +0300, Amir Vadai wrote:
> On 10/5/2014 12:35 PM, Amir Vadai wrote:
> > I am sending this patchset now since the merge window is near and don't want to
> > miss it.
> 
> A small clarification, since I didn't explain myself precisely enough:
> This patchset is not a WIP and ready for merge. The open issues
> aren't directly related to the series and will be addressed in
> incremental manner.


+2

Thanks Amir for this hard work.

Note that now the validate calls (GSO segmentation) is performed outside
of qdisc or device lock ( 55a93b3ea780 qdisc: validate skb without
holding lock) , its very easy to add a dev->gso_min_segs

I already have a patch for this, I am sending it right now.

Thanks !
