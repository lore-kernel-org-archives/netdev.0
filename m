From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bcm63xx_enet: avoid uninitialized variable warning
Date: Fri, 20 Jan 2017 11:46:00 -0500 (EST)
Message-ID: <20170120.114600.1285813871724893800.davem@davemloft.net>
References: <20170118145306.1004008-1-arnd@arndb.de>
 <20170118145306.1004008-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, xypron.glpk@gmx.de, linux-kernel@vger.kernel.org,
 bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, tremyfr@gmail.com
To: arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170118145306.1004008-3-arnd@arndb.de>
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
Date: Wed, 18 Jan 2017 15:52:53 +0100

> gcc-7 and probably earlier versions get confused by this function
> and print a harmless warning:
> 
> drivers/net/ethernet/broadcom/bcm63xx_enet.c: In function 'bcm_enet_open':
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:1130:3: error: 'phydev' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This adds an initialization for the 'phydev' variable when it is unused
> and changes the check to test for that NULL pointer to make it clear
> that we always pass a valid pointer here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Also applied, thanks.
