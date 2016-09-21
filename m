From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 20:58:33 +0200
Message-ID: <20160921185833.GC15732@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <57E1CDE3.5030404@fb.com>
 <20160921182657.67681e67@jkicinski-Precision-T1700>
 <CALx6S37CkP44ZSNZM3UNBMv_ECFS6tf5T_37VSMyBCjm9ejiDw@mail.gmail.com>
 <20160921194548.33b85cb3@jkicinski-Precision-T1700>
 <CALx6S34c6Mz=YpbiPcVNe38wTkxfjB9SWxaqtz1LivLeGzssRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>, Alexei Starovoitov <ast@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38754 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbcIUS6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 14:58:36 -0400
Received: by mail-wm0-f47.google.com with SMTP id l132so107738201wmf.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 11:58:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34c6Mz=YpbiPcVNe38wTkxfjB9SWxaqtz1LivLeGzssRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/16 at 11:50am, Tom Herbert wrote:
> 50 lines in one driver is not a big deal, 50 lines in a hundred
> drivers is! I learned this lesson in BQL which was well abstracted out
> to be minimally invasive but we still saw many issues because of the
> pecularities of different drivers.

You want to enable XDP in a hundred drivers? Are you planning to
deploy ISA NIC based ILA routers? ;-)
