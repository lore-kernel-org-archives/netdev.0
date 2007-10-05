From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 08:40:36 -0700
Message-ID: <20071005084036.52dc943c@freepuppy.rosehill>
References: <20071005.031209.57156822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43763 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756983AbXJEPku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:40:50 -0400
In-Reply-To: <20071005.031209.57156822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I just checked the following into net-2.6.24, besides minor
> tweaks and bug fixes, this is probably what is going to Linus.
> 
> I verified it builds no just on sparc64 but also even on 32-bit
> platforms such as x86. :-)
> 
> Thanks!

Output of checkpatch.pl for your patch:
CHECK: Use #include <linux/io.h> instead of <asm/io.h>
#114: FILE: drivers/net/niu.c:26:
+#include <asm/io.h>

ERROR: trailing whitespace
#632: FILE: drivers/net/niu.c:544:
+^I$

WARNING: braces {} are not necessary for single statement blocks
#691: FILE: drivers/net/niu.c:603:
+	if (lp->loopback_mode == LOOPBACK_PHY) {
+		test_cfg_val |= ((ENET_TEST_MD_PAD_LOOPBACK <<
+				  ENET_SERDES_TEST_MD_0_SHIFT) |
+				 (ENET_TEST_MD_PAD_LOOPBACK <<
+				  ENET_SERDES_TEST_MD_1_SHIFT) |
+				 (ENET_TEST_MD_PAD_LOOPBACK <<
+				  ENET_SERDES_TEST_MD_2_SHIFT) |
+				 (ENET_TEST_MD_PAD_LOOPBACK <<
+				  ENET_SERDES_TEST_MD_3_SHIFT));
+	}

CHECK: if this code is redundant consider removing it
#1109: FILE: drivers/net/niu.c:1021:
+#if 0

CHECK: if this code is redundant consider removing it
#1665: FILE: drivers/net/niu.c:1577:
+#if 0

CHECK: if this code is redundant consider removing it
#1703: FILE: drivers/net/niu.c:1615:
+#if 0

CHECK: if this code is redundant consider removing it
#1773: FILE: drivers/net/niu.c:1685:
+#if 0

CHECK: if this code is redundant consider removing it
#1816: FILE: drivers/net/niu.c:1728:
+#if 0

CHECK: if this code is redundant consider removing it
#1887: FILE: drivers/net/niu.c:1799:
+#if 0

ERROR: trailing whitespace
#1924: FILE: drivers/net/niu.c:1836:
+^I	       $

WARNING: multiple assignments should be avoided
#2442: FILE: drivers/net/niu.c:2354:
+	tmp = pkt_cnt = (cs & TX_CS_PKT_CNT) >> TX_CS_PKT_CNT_SHIFT;

CHECK: memory barrier without comment
#2457: FILE: drivers/net/niu.c:2369:
+	smp_mb();

WARNING: multiple assignments should be avoided
#2489: FILE: drivers/net/niu.c:2401:
+	rcr_done = work_done = 0;

WARNING: multiple assignments should be avoided
#3254: FILE: drivers/net/niu.c:3166:
+	first_rx_channel = first_tx_channel = 0;

ERROR: trailing whitespace
#4241: FILE: drivers/net/niu.c:4153:
+^Ival &= ~(XMAC_MIN_TX_MIN_PKT_SIZE | $

WARNING: braces {} are not necessary for single statement blocks
#4649: FILE: drivers/net/niu.c:4561:
+	if (limit < 0 &&
+	    (rd != 0 && wr != 1)) {
+		printk(KERN_ERR PFX "%s: IPP would not quiesce, "
+		       "rd_ptr[%llx] wr_ptr[%llx]\n",
+		       np->dev->name,
+		       (unsigned long long) nr64_ipp(IPP_DFIFO_RD_PTR),
+		       (unsigned long long) nr64_ipp(IPP_DFIFO_WR_PTR));
+	}

WARNING: multiple assignments should be avoided
#4950: FILE: drivers/net/niu.c:4862:
+	pkts = dropped = errors = bytes = 0;

WARNING: multiple assignments should be avoided
#4970: FILE: drivers/net/niu.c:4882:
+	pkts = errors = bytes = 0;

WARNING: multiple assignments should be avoided
#5207: FILE: drivers/net/niu.c:5119:
+	ipv6 = ihl = 0;

WARNING: multiple assignments should be avoided
#5219: FILE: drivers/net/niu.c:5131:
+		ip_proto = ihl = 0;

WARNING: multiple assignments should be avoided
#5342: FILE: drivers/net/niu.c:5254:
+		mrk = nfg = 0;

ERROR: use tabs not spaces
#5458: FILE: drivers/net/niu.c:5370:
+  ^Istruct niu *np = netdev_priv(dev);$

WARNING: multiple assignments should be avoided
#5512: FILE: drivers/net/niu.c:5424:
+		len = eeprom->len = np->eeprom_len - offset;

WARNING: line over 80 characters
#5786: FILE: drivers/net/niu.c:5698:
+		 * the firmware, and we're not supposed to change them.  Validate

WARNING: line over 80 characters
#5791: FILE: drivers/net/niu.c:5703:
+			printk(KERN_ERR PFX "Port %u, mis-matched LDG assignment "

WARNING: braces {} are not necessary for single statement blocks
#5890: FILE: drivers/net/niu.c:5802:
+	if (err < 0) {
+		return err;
+	}

WARNING: braces {} are not necessary for single statement blocks
#5895: FILE: drivers/net/niu.c:5807:
+	if (err < 0) {
+		return err;
+	}

ERROR: trailing whitespace
#5969: FILE: drivers/net/niu.c:5881:
+^I	$

WARNING: line over 80 characters
#6129: FILE: drivers/net/niu.c:6041:
+static int __devinit niu_phy_type_prop_decode(struct niu *np, const char *phy_prop)

WARNING: printk() should include KERN_ facility level
#6297: FILE: drivers/net/niu.c:6209:
+			printk("%02x ", dev->perm_addr[i]);

WARNING: multiple assignments should be avoided
#6481: FILE: drivers/net/niu.c:6393:
+		rx_chans_per_10g = rx_chans_per_1g =

WARNING: multiple assignments should be avoided
#6483: FILE: drivers/net/niu.c:6395:
+		tx_chans_per_10g = tx_chans_per_1g =

WARNING: multiple assignments should be avoided
#6497: FILE: drivers/net/niu.c:6409:
+	tot_rx = tot_tx = 0;

WARNING: braces {} are not necessary for single statement blocks
#6531: FILE: drivers/net/niu.c:6443:
+	if (tot_rx < NIU_NUM_RXCHAN || tot_tx < NIU_NUM_TXCHAN) {
+		printk(KERN_WARNING PFX "niu%d: Driver bug, wasted channels, "
+		       "RX[%d] TX[%d]\n",
+		       parent->index, tot_rx, tot_tx);
+	}

WARNING: multiple assignments should be avoided
#6777: FILE: drivers/net/niu.c:6689:
+	lp->speed = lp->active_speed = SPEED_INVALID;

WARNING: multiple assignments should be avoided
#6778: FILE: drivers/net/niu.c:6690:
+	lp->duplex = lp->active_duplex = DUPLEX_INVALID;

CHECK: if this code is redundant consider removing it
#6779: FILE: drivers/net/niu.c:6691:
+#if 0

WARNING: line over 80 characters
#7048: FILE: drivers/net/niu.c:6960:
+		printk(KERN_ERR PFX "%s: OF node lacks local-mac-address property\n",

WARNING: braces {} are not necessary for single statement blocks
#7052: FILE: drivers/net/niu.c:6964:
+	if (prop_len != dev->addr_len) {
+		printk(KERN_ERR PFX "%s: OF MAC address prop len (%d) is wrong.\n",
+		       dp->full_name, prop_len);
+	}

WARNING: line over 80 characters
#7053: FILE: drivers/net/niu.c:6965:
+		printk(KERN_ERR PFX "%s: OF MAC address prop len (%d) is wrong.\n",

WARNING: printk() should include KERN_ facility level
#7065: FILE: drivers/net/niu.c:6977:
+			printk("%02x ", dev->perm_addr[i]);

WARNING: braces {} are not necessary for single statement blocks
#7209: FILE: drivers/net/niu.c:7121:
+	for (i = 0; i < p->num_ports; i++) {
+		buf += sprintf(buf,
+			       (i == 0) ? "%d" : " %d",
+			       arr[i]);
+	}

ERROR: "foo * bar" should be "foo *bar"
#7249: FILE: drivers/net/niu.c:7161:
+static struct niu_parent * __devinit niu_new_parent(struct niu *np,

ERROR: "foo * bar" should be "foo *bar"
#7316: FILE: drivers/net/niu.c:7228:
+static struct niu_parent * __devinit niu_get_parent(struct niu *np,

ERROR: do not initialise statics to 0 or NULL
#7438: FILE: drivers/net/niu.c:7350:
+	static int niu_version_printed = 0;

ERROR: "foo * bar" should be "foo *bar"
#7444: FILE: drivers/net/niu.c:7356:
+static struct net_device * __devinit niu_alloc_and_init(struct device *gen_dev,

WARNING: line over 80 characters
#7447: FILE: drivers/net/niu.c:7359:
+							const struct niu_ops *ops,

WARNING: line over 80 characters
#7819: FILE: drivers/net/niu.c:7731:
+static int __devinit niu_of_probe(struct of_device *op, const struct of_device_id *match)

ERROR: trailing whitespace
#8318: FILE: drivers/net/niu.h:284:
+#define XMAC_ADDR2^I		0x000b0UL $

ERROR: need space after that ',' (ctx:VxV)
#9610: FILE: drivers/net/niu.h:1576:
+#define RDC_TBL(TBL,SLOT)		(FZC_ZCP + 0x10000UL + \
                    ^

WARNING: line over 80 characters
#10002: FILE: drivers/net/niu.h:1968:
+#define  RXDMA_CFIG1_MBADDR_H		0x0000000000000fffULL /* mboxaddr 43:32 */

WARNING: line over 80 characters
#10005: FILE: drivers/net/niu.h:1971:
+#define  RXDMA_CFIG2_MBADDR_L		0x00000000ffffffc0ULL /* mboxaddr 31:6 */

CHECK: spinlock_t definition without comment
#11039: FILE: drivers/net/niu.h:3005:
+	spinlock_t		lock;

WARNING: line over 80 characters
#11203: FILE: drivers/net/niu.h:3169:
+#define NIU_FLAGS_MCAST			0x00200000 /* multicast filter enabled */

Your patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.
