From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Adding Support for Jumbo Frames up to 10240
 Bytes in SAMA5D3
Date: Sat, 08 Jul 2017 10:40:20 +0100 (WEST)
Message-ID: <20170708.104020.1241751447608549551.davem@davemloft.net>
References: <20170705153616.15965-1-nicolas.ferre@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rafalo@cadence.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 alexandre.belloni@free-electrons.com, vardhanraj4143@gmail.com,
 linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@microchip.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170705153616.15965-1-nicolas.ferre@microchip.com>
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

From: Nicolas Ferre <nicolas.ferre@microchip.com>
Date: Wed, 5 Jul 2017 17:36:16 +0200

> From: vishnuvardhan <vardhanraj4143@gmail.com>
> 
> As per the SAMA5D3 device specification it supports Jumbo frames.
> But the suggested flag and length of bytes it supports was not updated
> in this driver config_structure.
> The maximum jumbo frames the device supports :
> 10240 bytes as per the device spec.
> 
> While changing the MTU value greater than 1500, it threw error:
> sudo ifconfig eth1 mtu 9000
> SIOCSIFMTU: Invalid argument
> 
> Add this support to driver so that it works as expected and designed.
> 
> Signed-off-by: vishnuvardhan <vardhanraj4143@gmail.com>
> [nicolas.ferre@microchip.com: modify slightly commit msg]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@microchip.com>

Applied, thank you.
