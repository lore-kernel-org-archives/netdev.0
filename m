From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 18:58:51 +0200
Message-ID: <20160920165851.GC3291@pox.localdomain>
References: <20160920102943.24732097@brouer.com>
 <20160920133300.144037fd@redhat.com>
 <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
 <20160920154036.GA98644@ast-mbp.thefacebook.com>
 <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
 <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920180609.148874b5@redhat.com>
 <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920182717.2de9541e@redhat.com>
 <20160920164526.GB99429@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35179 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933063AbcITQ6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:58:54 -0400
Received: by mail-wm0-f51.google.com with SMTP id l132so220111901wmf.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:58:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160920164526.GB99429@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 09:45am, Alexei Starovoitov wrote:
> that's a great idea. Instead of adding aborted, ring_full, blahblah counters
> everywhere that cost performance, let's add tracepoints that are nops
> when not in use.
> And if all drivers call the same tracepoints it will be even better.
> Monitoring trace_xdp_aborted tracepoint would be generic way to debug
> 'divide by zero'.

Not opposed but I still need an indication to start tracing ;-) A
single counter would be enough though.
