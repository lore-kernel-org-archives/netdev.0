From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 17:35:30 +0300
Message-ID: <CAJ3xEMiVXonPkJsve2UuWtTs2wqBnV_jrYMuJ1yvccBTeAFM2w@mail.gmail.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	<1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
	<1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>, saeedm@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:59782 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaI1Ofb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 10:35:31 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so12241535obc.12
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 07:35:30 -0700 (PDT)
In-Reply-To: <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 1:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> First I implemented skb->xmit_more support, and pktgen throughput
> went from ~5Mpps to ~10Mpps.
>
> Then, looking closely at this driver I found false sharing problems that
> should be addressed by this patch, as my pktgen now reaches 14.7 Mpps
> on a single TX queue, with a burst factor of 8.
>
> So this patch in a whole permits to improve raw performance on a single
> TX queue from about 5 Mpps to 14.7 Mpps.

Eric,

cool!! the team here will take a look this week. I assume we might
want to break the fifteen changes into multiple patches...

Thanks again for all your great work

Or.
