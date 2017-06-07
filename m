From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Wed, 7 Jun 2017 02:48:44 +0200
Message-ID: <20170607004844.GH18198@lunn.ch>
References: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
 <20170606.143824.717466091308335341.davem@davemloft.net>
 <20170606185532.2byjdonwsyan2asl@ast-mbp.dhcp.thefacebook.com>
 <20170606.150151.1650636686526694540.davem@davemloft.net>
 <20170606224451.76732gjmf6vaetxx@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        jgunthorpe@obsidianresearch.com, ilant@mellanox.com,
        saeedm@dev.mellanox.co.il, dledford@redhat.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        jsorensen@fb.com, andy.shevchenko@gmail.com,
        linux-fpga@vger.kernel.org, yi1.li@linux.intel.com,
        borisp@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39080 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdFGAtA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 20:49:00 -0400
Content-Disposition: inline
In-Reply-To: <20170606224451.76732gjmf6vaetxx@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 03:44:53PM -0700, Alexei Starovoitov wrote:
> On Tue, Jun 06, 2017 at 03:01:51PM -0400, David Miller wrote:
> > From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> > Date: Tue, 6 Jun 2017 11:55:33 -0700
> > 
> > > If in the future mlx will make it into the nic in a way that
> > > encryption shares all memory management logic and there is no fpga
> > > at all then it indeed will be similar to tc offload. Right now it's
> > > not and needs different sw architecture.
> > 
> > If the visible effect is identical, I fundamentally disagree with you.
> > 
> > I don't care if there is a frog sitting on the PHY that transforms
> > the packets, it's all the same if the visible behavior is identical.
> 
> that frog is a good example why we disagree.
> I need to check the pulse of that frog and last time it ate.

It is probably over-engineered for a single frog, but maybe you could
use a modified RFC 2795?

    Andrew
