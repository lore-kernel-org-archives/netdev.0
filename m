From: David Miller <davem@davemloft.net>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 06 Jun 2017 14:38:24 -0400 (EDT)
Message-ID: <20170606.143824.717466091308335341.davem@davemloft.net>
References: <20170606174233.w377ctwtapzccsk7@ast-mbp.dhcp.thefacebook.com>
        <20170606.134726.416045938000214127.davem@davemloft.net>
        <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe@obsidianresearch.com, ilant@mellanox.com,
        saeedm@dev.mellanox.co.il, dledford@redhat.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        jsorensen@fb.com, andy.shevchenko@gmail.com,
        linux-fpga@vger.kernel.org, atull@opensource.altera.com,
        yi1.li@linux.intel.com, borisp@mellanox.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdFFSia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:38:30 -0400
In-Reply-To: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 6 Jun 2017 11:34:59 -0700

> fpga is a separate device with its own phy and mac layers, its
> own queues, packet parsing and rdma logic.

Because that's how they bolted it onto the ASIC in current
implementation, it might not always be that way and be fully
integrated in the future.

And I stress the word "implementation" as in "implementation detail"
the visible behavior is going to be the same, the difference is how
the thing is hooked up and maybe how you program it.
