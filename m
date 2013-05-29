From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v5 01/13] net: mv643xx_eth: use phy_disconnect instead
 of phy_detach
Date: Wed, 29 May 2013 16:00:53 -0400
Message-ID: <20130529200053.GA31290@titan.lakedaemon.net>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369855975-21489-2-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1369855975-21489-2-git-send-email-sebastian.hesselbarth@gmail.com>
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

Sebastian,

On Wed, May 29, 2013 at 09:32:43PM +0200, Sebastian Hesselbarth wrote:
> Using a separated mdio bus driver with mvmdio, phy_detach on network device
> removal will not stop the phy and finally lead to NULL pointer dereference
> in mvmdio due to non-existent network device. Use phy_disconnect instead
> to properly stop phy device from accessing network device prior removal of
> the network device.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Note: I observed this behavior when removing a modular mv643xx_eth driver
> after attaching it to a phy handled by (also modular) mvmdio. The mvmdio
> conversion has been done in
> 
> commit c3a07134e6aa5b93a37f72ffa3d11fadf72bf757
>  ("mv643xx_eth: convert to use the Marvell Orion MDIO driver")
> 
> and should go back any -stable version with that commit (propably only 3.9)

It looks like just v3.10-rcX, here.

thx,

Jason.
