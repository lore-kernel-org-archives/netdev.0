From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: constify mdiobb_ops structures
Date: Mon, 16 Jan 2017 13:47:01 -0500 (EST)
Message-ID: <20170116.134701.1316974977589117728.davem@davemloft.net>
References: <1484330546-16569-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, pantelis.antoniou@gmail.com,
        vbordug@ru.mvista.com, sergei.shtylyov@cogentembedded.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-renesas-soc@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1484330546-16569-1-git-send-email-bhumirks@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Fri, 13 Jan 2017 23:32:26 +0530

> Declare mdiobb_ops structures as const as they are only stored in the
> ops field of mdiobb_ctrl structures. This field is of type const, so
> mdiobb_ops structures having this property can be declared const too.

This patch doesn't apply cleanly to net-next, please respin.
