From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net: fec: Add support for multiple phys on mdiobus
Date: Mon, 21 Jan 2013 09:56:24 +0100
Message-ID: <50FD02B8.8080401@grandegger.com>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.guo@linaro.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 01/21/2013 09:37 AM, Sascha Hauer wrote:
> There may be multiple phys on an mdio bus. This series adds support
> for this to the fec driver. I recently had a board which has a switch
> connected to the fec's mdio bus, so I had to pick the correct phy.

Pick one PHY from a switch port? Well, does a PHY-less (or fixed-link)
configuration for a switch not make more sense? Various ARM Ethernet
contoller drivers do not support it. I recently needed a hack for an
AT91 board.

Wolfgang.
