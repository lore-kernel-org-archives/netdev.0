From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH] net: mvneta: set rx mode during resume if interface is
 running
Date: Tue, 28 Mar 2017 10:27:20 +0800
Message-ID: <20170328102720.71f530f8@xhacker>
References: <20170327105905.1404-1-jszhang@marvell.com>
 <20170327.161534.60442857212281980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170327.161534.60442857212281980.davem@davemloft.net>
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

Dear David,

On Mon, 27 Mar 2017 16:15:34 -0700 David Miller wrote:

> From: Jisheng Zhang <jszhang@marvell.com>
> Date: Mon, 27 Mar 2017 18:59:05 +0800
> 
> > I found a bug by:
> > 
> > 0. boot and start dhcp client
> > 1. echo mem > /sys/power/state
> > 2. resume back immediately
> > 3. don't touch dhcp client to renew the lease
> > 4. ping the gateway. No acks
> > 
> > Usually, after step2, the DHCP lease isn't expired, so in theory we
> > should resume all back. But in fact, it doesn't. It turns out
> > the rx mode isn't resumed correctly. This patch fixes it by adding
> > mvneta_set_rx_mode(dev) in the resume hook if interface is running.
> > 
> > Signed-off-by: Jisheng Zhang <jszhang@marvell.com>  
> 
> This doesn't apply cleanly to the net tree, please respin.

This patch is generated against net-next, for mvneta suspend/resume support
is added into net-next recently. I did need to use the "[PATCH net-next]" for
the patch title, will take care in the future.

Sorry for confusion,
Jisheng
