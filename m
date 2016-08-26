From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] smc91x: always use 8-bit access if necessary
Date: Fri, 26 Aug 2016 11:42:47 +0200
Message-ID: <2740439.XeNYfcEoZp@wuerfel>
References: <20160825144633.1850889-1-arnd@arndb.de>
 <20160825223308.GJ1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>,
 Robert Jarzmik <robert.jarzmik@free.fr>,
 "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160825223308.GJ1041@n2100.armlinux.org.uk>
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

On Thursday, August 25, 2016 11:33:08 PM CEST Russell King - ARM Linux wrote:
> 
> This is insufficient.  If you look at how SMC_REG works, you'll notice
> that it has side effects which can disrupt other accesses (it reads
> the bank register if debugging is enabled.)

Ok, got it.

	Arnd
