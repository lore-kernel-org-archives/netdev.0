From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/8] net: Add device tree support to LPC32xx
Date: Mon, 2 Apr 2012 19:37:54 +0000
Message-ID: <201204021937.54567.arnd@arndb.de>
References: <1333391587-26290-1-git-send-email-stigge@antcom.de>
 <1333391587-26290-4-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: a.zummo@towertech.it, srinivas.bakki@nxp.com,
 linux-watchdog@vger.kernel.org, rtc-linux@googlegroups.com,
 gregkh@linuxfoundation.org, w.sang@pengutronix.de, kevin.wells@nxp.com,
 linux-kernel@vger.kernel.org, wim@iguana.be, arm@kernel.org,
 linux-i2c@vger.kernel.org, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, jonsmirl@gmail.com
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333391587-26290-4-git-send-email-stigge@antcom.de>
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

On Monday 02 April 2012, Roland Stigge wrote:
> 
> +       if (pdev->dev.of_node && of_get_property(pdev->dev.of_node,
> +                                                "use-iram", NULL))
> +               pldat->use_iram = true;
> +       else
> +               pldat->use_iram = false;
> +

One more thing I just noticed:

this is equivalent to the much shorter 

	pldat->use_iram = of_property_read_bool(pdev->dev.of_node, "use-iram");

Everything else looks good here.

	Arnd
