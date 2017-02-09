From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] ARM: orion: remove unused
 wnr854t_switch_plat_data
Date: Thu, 09 Feb 2017 17:06:16 -0500 (EST)
Message-ID: <20170209.170616.2056403989254038271.davem@davemloft.net>
References: <20170208212431.2924390-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, jason@lakedaemon.net,
 netdev@vger.kernel.org, linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
 gregory.clement@free-electrons.com, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170208212431.2924390-1-arnd@arndb.de>
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

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  8 Feb 2017 22:24:19 +0100

> The other instances of this structure got removed along with the MDIO
> device change, but this one was left behind and needs to be removed
> as well:
> 
> arch/arm/mach-orion5x/wnr854t-setup.c:109:44: error: 'wnr854t_switch_plat_data' defined but not used [-Werror=unused-variable]
>  static struct dsa_platform_data __initdata wnr854t_switch_plat_data = {
> 
> Fixes: 575e93f7b5e6 ("ARM: orion: Register DSA switch as a MDIO device")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
