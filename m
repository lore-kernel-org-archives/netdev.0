From: Wolfgang Grandegger <wg@grandegger.com>
Subject: imx6q: poor FEC Gigabit implementation
Date: Mon, 30 Jul 2012 21:24:07 +0200
Message-ID: <5016DF57.2060207@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org,
 Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

Hello,

I did some Gigabit performance measurements with the i.MX6Q Sabrelite
board. I measure an UDP throughput of 470 Mb/s to an external host,
which is already very close to the theoretical limit listed in the Chip
Errata ERR004512 for the i.MX 6Dual/6Quad, Rev. C, 2/2012.

At a closer look to the driver I realized that there is no support for

  - NAPI
  - IP checksum offloading
  - Jumbo frames

According to the manual, these features are support by the ENET via
enhanced buffer descriptors. Even if they will not increase the
performance due to the mentioned system limitation, they should reduce
the interrupt and CPU load significantly. I did some quick tests with IP
checksum offloading and Jumbo frames but without success. Are there any
known issues? Is anybody already working on an enhanced FEC Gigabit
ethernet driver?

TIA.

Wolfgang.
