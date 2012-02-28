From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Tue, 28 Feb 2012 14:13:34 -0500 (EST)
Message-ID: <20120228.141334.569125676685228205.davem@davemloft.net>
References: <4F4CD1D8.8030102@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, baruch@tkos.co.il, ian.campbell@citrix.com,
 netdev@vger.kernel.org, eilong@broadcom.com, kevin.wells@nxp.com,
 w.sang@pengutronix.de, jeffrey.t.kirsher@intel.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: stigge@antcom.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4F4CD1D8.8030102@antcom.de>
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

From: Roland Stigge <stigge@antcom.de>
Date: Tue, 28 Feb 2012 14:08:40 +0100

> For the case that it _isn't_ initialized already, is it the right thing
> to use a hard coded default MAC address to be replaced by the final one
> in userspace? (I found such examples in some current micrel/ and amd/
> drivers.)

You use a randomized ethernet address which can subsequently be fixed up
by userspace, and we have very specific interfaces to make this very
easy for you.  It even sets an attribute which userland can query to see
that the device has a randomized ethernet address rathern than a true
assigned permanent one.
