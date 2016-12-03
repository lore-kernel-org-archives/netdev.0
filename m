From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/4]: Allow head adjustment in XDP prog
Date: Sat, 3 Dec 2016 16:17:34 +0100
Message-ID: <20161203161734.2aeaf170@redhat.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751241AbcLCPRk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 10:17:40 -0500
In-Reply-To: <1480721013-1047541-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Dec 2016 15:23:29 -0800
Martin KaFai Lau <kafai@fb.com> wrote:

> This series adds a helper to allow head adjustment in XDP prog.  mlx4
> driver has been modified to support this feature.  An example is written
> to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
> out.

Hi Martin,

It is great to see work in this area.

Push/pop of headers is listed as on of the missing features here:
 https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/missing_features.html
We can hopefully soon cross that of the list :-)

Header push and pop desc:
 https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/requirements.html#header-push-and-pop

Thanks for working on this! :-)))
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
