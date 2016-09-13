From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Tue, 13 Sep 2016 10:37:32 -0700
Message-ID: <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
         <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
         <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160912230745.GA24171@ast-mbp.thefacebook.com>
         <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
         <20160913012815.GB25756@ast-mbp.thefacebook.com>
         <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
         <20160913171340.GA37341@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32979 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753968AbcIMRhf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 13:37:35 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so9853897pfb.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 10:37:35 -0700 (PDT)
In-Reply-To: <20160913171340.GA37341@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-13 at 10:13 -0700, Alexei Starovoitov wrote:

> I'm afraid the point 'only for debugging' still didn't make it across.
> xdp+e1k is for development (and debugging) of xdp-type of bpf
> programs and _not_ for debugging of xdp itself, kernel or anything else.
> The e1k provided interfaces and behavior needs to match exactly
> what real hw nics (like mlx4, mlx5, igxbe, i40e) will do.
> Doing special hacks are not acceptable. Therefore your
> 'proposed fix' misses the mark, since:
> 1. ignoring bql/qdisc is not a bug, but the requirement
> 2. such 'fix' goes against the goal above since behaviors will be
> different and xdp developer won't be able to build something like
> xdp loadbalancer in the kvm.
> 


Is e1k the only way a VM can receive and send packets ?

Instead of adding more cruft to a legacy driver, risking breaking real
old machines, I am sure we can find modern alternative.
