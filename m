From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Add support for led triggers on phy link state
 change
Date: Tue, 18 Oct 2016 11:57:07 -0400 (EDT)
Message-ID: <20161018.115707.1632276930668736889.davem@davemloft.net>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, rpurdie@rpsys.net, gregkh@linuxfoundation.org,
 Larry.Finger@lwfinger.net, j.anaszewski@samsung.com,
 linux-leds@vger.kernel.org, mlindner@marvell.com
To: zach.brown@ni.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@ni.com>
Date: Mon, 17 Oct 2016 10:49:51 -0500

> Fix skge driver that declared enum contants that conflicted with enum
> constants in linux/leds.h
> 
> Create function that encapsulates actions taken during the adjust phy link step
> of phy state changes.
> 
> Create function that provides list of speeds currently supported by the phy.
> 
> Add support for led triggers on phy link state changes by adding
> a config option. When set the config option will create a set of led triggers
> for each phy device. Users can use the led triggers to represent link state
> changes on the phy.

Ok this looks good enough for now, we can expand and improve upon it
later if necessary.

Series applied, thanks Zach.
