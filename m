From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Mon, 12 Jun 2017 10:17:46 -0600
Message-ID: <20170612161746.GC24829@obsidianresearch.com>
References: <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170605151724.GA20182@obsidianresearch.com>
 <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170606161709.GA8671@obsidianresearch.com>
 <CALzJLG9Rdjme2piWX+CDeHZZebWArM_wGjLJPh8=COOxBHuFkw@mail.gmail.com>
 <20170607154858.GA30124@obsidianresearch.com>
 <CALzJLG8epxWp1pmTd_fxOUfzXF5YoOFfnrRBJ0-YZVL1Gi_yOw@mail.gmail.com>
 <20170607192132.GA10929@obsidianresearch.com>
 <1497047041.7171.234.camel@redhat.com>
 <CC17D182-E8FF-48C7-8667-67429C6F8259@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Ilan Tayari <ilant@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        "linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
        Alan Tull <atull@opensource.altera.com>,
        "yi1.li@linux.intel.com" <yi1.li@linux.intel.com>,
        Boris Pismenny <borisp@mellanox.com>
To: Majd Dibbiny <majd@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:38515 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752740AbdFLQRv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 12:17:51 -0400
Content-Disposition: inline
In-Reply-To: <CC17D182-E8FF-48C7-8667-67429C6F8259@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 02:11:13PM +0000, Majd Dibbiny wrote:

> >> This is especially true for mlx nics as there are many raw packet
> >> bypass mechanisms available to userspace.

> All of the Raw packet bypass mechanisms are restricted to
> CAP_NET_RAW, and thus malicious users can't simply open a RAW Packet
> QP and send it to the FPGA..

It is big expansion of CAP_NET_RAW to also basically also include
reconfiguring ipsec xfrm.

Plus, if someone configures ethernet bridging (eg in a VM situation)
then could a hacked VM reconfigure this FPGA?

Jason
