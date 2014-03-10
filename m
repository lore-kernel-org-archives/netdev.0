From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Sun, 09 Mar 2014 20:30:01 -0400 (EDT)
Message-ID: <20140309.203001.1318893833441564547.davem@davemloft.net>
References: <1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20140309.191235.1047481546773873653.davem@davemloft.net>
	<531CF864.9040406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <531CF864.9040406@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Mon, 10 Mar 2014 00:25:24 +0100

> There is no way to determine if a bootloader is broken or not. The
> sysfs knob allows to provide a use case based decision. Of course,
> we can invent some freaky device tree property but that the DT
> maintainers will not like either.

My point is that whatever mechanism is used to "decide" that the sysfs
knob gets set, can also be used to "decide" that a DT property is
instantiated in the device tree.
