From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] davinci_emac.c: Fix IFF_ALLMULTI setup
Date: Mon, 21 Oct 2013 23:20:41 +0530
Message-ID: <52656971.3020509@ti.com>
References: <5265640C.4070201@cogentembedded.com> <1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lad Prabhakar <prabhakar.csengg@gmail.com>,
	Jingoo Han <jg1.han@samsung.com>,
	Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Mariusz Ceier <mceier+kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382377504-24688-1-git-send-email-mceier+kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 21 October 2013 11:15 PM, Mariusz Ceier wrote:
> When IFF_ALLMULTI flag is set on interface and IFF_PROMISC isn't,
> emac_dev_mcast_set should only enable RX of multicasts and reset
> MACHASH registers.
>
> It does this, but afterwards it either sets up multicast MACs
> filtering or disables RX of multicasts and resets MACHASH registers
> again, rendering IFF_ALLMULTI flag useless.
>
> This patch fixes emac_dev_mcast_set, so that multicast MACs filtering and
> disabling of RX of multicasts are skipped when IFF_ALLMULTI flag is set.
>
> Tested with kernel 2.6.37.
>
> Signed-off-by: Mariusz Ceier <mceier+kernel@gmail.com>
> ---
Can you add [PATCH v2] in your subject in future so that it will be
easier to the maintainer to pick the latest version of the patch.

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
