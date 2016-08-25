From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Thu, 25 Aug 2016 16:45:12 +0200
Message-ID: <3062310.z9h3CgCZ7p@wuerfel>
References: <20160825144314.1850730-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Robert Jarzmik <robert.jarzmik@free.fr>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Russell King <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160825144314.1850730-1-arnd@arndb.de>
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

On Thursday, August 25, 2016 4:43:04 PM CEST Arnd Bergmann wrote:
>  drivers/net/ethernet/smsc/smc91x.h | 50 +++++++++++++++++++++++---------------
>  1 file changed, 30 insertions(+), 20 deletions(-)
> 
> While this patch fixes one bug on Neponset, it probably doesn't address
> the one that Russell ran into first, so this is for review only for now,
> until the remaining problem(s) have been worked out.
> 

The comment should have been on another patch, my mistake. please
see v2.

	Arnd
