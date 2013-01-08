From: Dirk Behme <dirk.behme@de.bosch.com>
Subject: Re: [PATCH 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Tue, 8 Jan 2013 10:55:26 +0100
Message-ID: <50EBED0E.6090608@de.bosch.com>
References: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "B38611@freescale.com" <B38611@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
 "lznuaa@gmail.com" <lznuaa@gmail.com>,
 "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
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

On 08.01.2013 09:43, Frank Li wrote:
> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
> There will be many packages lost because FIFO over run.
> 
> This patch enable pause frame flow control.

Many thanks for this patch!

Do we want/need anything similar for U-Boot, too?

Some people want to boot the system from U-Boot attached to 1G network 
and have issues there, too.

Best regards

Dirk
