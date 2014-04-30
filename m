From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by
 ipv4: fix path MTU discovery with connection tracking)
Date: Wed, 30 Apr 2014 16:34:51 +0200
Message-ID: <1398868491.5474.10.camel@sakura.staff.proxad.net>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
	 <20140429143324.GB12781@macbook.localnet>
	 <1398782535.4033.11.camel@sakura.staff.proxad.net>
	 <20140429144513.GA12969@macbook.localnet>
	 <1398785021.4033.19.camel@sakura.staff.proxad.net>
	 <1398785841.29914.146.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:57762 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422652AbaD3Oex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 10:34:53 -0400
In-Reply-To: <1398785841.29914.146.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2014-04-29 at 08:37 -0700, Eric Dumazet wrote:

> Hmm... maybe its finally time to rename local_df to ignore_df, as
> Maze suggested some time ago ...

It would have indeed helped me to understand the purpose of this flag at
first glance.

About the patch I sent, I'm not well equipped to test mainline kernels
wrt the bug I reported (it does not boot on my embedded device), so I'd
prefer someone else to cook the patch and actually test it.

Thanks,

-- 
Maxime
