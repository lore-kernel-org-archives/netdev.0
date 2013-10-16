From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/ethernet: cpsw: Bugfix interrupts before enabling napi
Date: Wed, 16 Oct 2013 18:28:36 +0530
Message-ID: <525E8D7C.5050702@ti.com>
References: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
 Peter Korsgaard <peter@korsgaard.com>, Florian Fainelli <florian@openwrt.org>,
 linux-arm-kernel@lists.infradead.org
To: Markus Pargmann <mpa@pengutronix.de>, "David S. Miller"
 <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Monday 14 October 2013 12:47 AM, Markus Pargmann wrote:
> If interrupts happen before napi_enable was called, the driver will not
> work as expected. Network transmissions are impossible in this state.
> This bug can be reproduced easily by restarting the network interface in
> a loop. After some time any network transmissions on the network
> interface will fail.
>
> This patch fixes the bug by enabling napi before enabling the network
> interface interrupts.
>
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
