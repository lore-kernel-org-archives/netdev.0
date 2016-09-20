From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 22:47:47 +0200
Message-ID: <20160920224747.23b7a33b@redhat.com>
References: <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
        <20160920102943.24732097@brouer.com>
        <20160920133300.144037fd@redhat.com>
        <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
        <20160920154036.GA98644@ast-mbp.thefacebook.com>
        <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
        <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920180609.148874b5@redhat.com>
        <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920182717.2de9541e@redhat.com>
        <20160920164526.GB99429@ast-mbp.thefacebook.com>
        <1474393160.23058.39.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920205939.6a4522df@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751783AbcITUry (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 16:47:54 -0400
In-Reply-To: <20160920205939.6a4522df@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 20 Sep 2016 20:59:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Tue, 20 Sep 2016 10:39:20 -0700  Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
[...]
> 
> > Many existing supervision infrastructures collect device snmp
> > counters, and run as unprivileged programs.   
> 
> A supervision infrastructures is a valid use-case. It again indicate
> that such XDP stats need to structured, not just a random driver
> specific ethtool counter, to make it easy for such collection daemons.
> 
> 
> > tracepoints might not fit the need here, compared to a mere
> > tx_ring->tx_drops++  
> 
> I do see your point.  I really liked the tracepoint idea, but now I'm
> uncertain again...

I've document the need for Troubleshooting and Monitoring, so we don't
forget about it. See:

Commit:
 https://github.com/netoptimizer/prototype-kernel/commit/3925249089ae4

Online doc:
 https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/userspace_api.html#troubleshooting-and-monitoring


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
