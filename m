From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Thu, 17 May 2012 19:03:46 -0400 (EDT)
Message-ID: <20120517.190346.175685939436302276.davem@davemloft.net>
References: <1337274702-19536-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, s.hauer@pengutronix.de,
 romieu@fr.zoreil.com, joe@perches.com, gfm@funxed.com, festevam@gmail.com,
 linux-arm-kernel@lists.infradead.org
To: jaccon.bastiaansen@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1337274702-19536-1-git-send-email-jaccon.bastiaansen@gmail.com>
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

From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: Thu, 17 May 2012 19:11:42 +0200

> The use of the inw/outw functions by the cs89x0 platform driver
> results in NULL pointer references on ARM platforms and
> platforms that do not provide ISA-style programmed I/O accessors.
> 
> Using inw/outw also accesses the wrong address space on platforms
> that have a PCI I/O space that is not identity-mapped into the
> physical address space.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

I could nit-pick more on this patch, but it's such a significant
improvement I'm just going to apply this V3 as-is to net-next.

Thanks.
