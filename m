From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: net: fec: fix regression on i.MX28 introduced by rx_copybreak support
Date: Tue, 28 Oct 2014 14:22:55 +0100
Message-ID: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
 Frank Li <Frank.Li@freescale.com>, linux-kernel@vger.kernel.org,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
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

Changes wrt. v1:
- added some cleanup patches
- simplify handling of 'quirks' flags as suggested by Russell King.
- remove DIV_ROUND_UP() from byte swapping loop as suggested by
  Eric Dumazet

Changes wrt. v2:
- rebased against next-20141028
- added some more cleanups in fec.h
- removed unused return value from swap_buffer()
- fixed messed swab32s() call in swap_buffer2()
- fixed messed up setup of fep->quirks
