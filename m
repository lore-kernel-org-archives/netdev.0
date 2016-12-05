From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 0/4]: Allow head adjustment in XDP prog
Date: Mon, 5 Dec 2016 17:53:02 +0000
Message-ID: <20161205175302.0d5d4fa7@jkicinski-Precision-T1700>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:6973 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751100AbcLERxH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 12:53:07 -0500
In-Reply-To: <1480821446-4122277-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Dec 2016 19:17:22 -0800, Martin KaFai Lau wrote:
> This series adds a helper to allow head adjusting in XDP prog.  mlx4
> driver has been modified to support this feature.  An example is written
> to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
> out.

Can we just add a feature to one of four drivers which support XDP
today and AFAICT leave it completely broken on remaining tree?

I'm not seeing any way for the drivers to inform the stack about their
capabilities, would that not be a pre-requisite?
