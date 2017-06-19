From: huaixin chang <hansechang@gmail.com>
Subject: Re: [RFC PATCH v2 12/17] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Mon, 19 Jun 2017 17:21:25 +0800
Message-ID: <99CF0FE4-4CF3-486F-9DF2-E467835E7418@gmail.com>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
 <20170502153955.9304.75647.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: quoted-printable
Cc: huaixin chang <hansechang@gmail.com>, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33410 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdFSJVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 05:21:30 -0400
Received: by mail-pf0-f195.google.com with SMTP id w12so15543483pfk.0
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 02:21:29 -0700 (PDT)
In-Reply-To: <20170502153955.9304.75647.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> =D4=DA 2017=C4=EA5=D4=C22=C8=D5=A3=AC=CF=C2=CE=E711:39=A3=ACJohn =
Fastabend <john.fastabend@gmail.com> =D0=B4=B5=C0=A3=BA
>=20
> The sch_mq qdisc creates a sub-qdisc per tx queue which are then
> called independently for enqueue and dequeue operations. However
> statistics are aggregated and pushed up to the "master" qdisc.
>=20
> This patch adds support for any of the sub-qdiscs to be per cpu
> statistic qdiscs. To handle this case add a check when calculating
> stats and aggregate the per cpu stats if needed.
>=20
> Also exports __gnet_stats_copy_queue() to use as a helper function.

Maybe mq_dump_class_stats() should handle per cpu statistic sub-qdiscs =
too.=
