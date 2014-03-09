From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Sun, 09 Mar 2014 19:12:35 -0400 (EDT)
Message-ID: <20140309.191235.1047481546773873653.davem@davemloft.net>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Fri,  7 Mar 2014 12:34:52 +0100

> commit 1211ce53077164e0d34641d0ca5fb4d4a7574498
>   ("net: phy: resume/suspend PHYs on attach/detach")
> introduced a feature to suspend PHYs when entering halted state.
> 
> Unfortunately, not all bootloaders properly power-up PHYs on reset
> and fail to access ethernet because the PHY is still powered down.
> 
> Therefore, this adds code and documentation for a sysfs attribute to
> allow/deny PHYs to be suspended on a per-PHY basis. Disabling that
> attribute prevents PHYs from being suspended when entering halted state.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Reported-by: Andrew Lunn <andrew@lunn.ch>

I know you won't like what I have to say, but I want to see a solution
without this sysfs knob.

First of all, you obviously have a way to end up having the sysfs knob
get set on the appropriate systems.

Therefore, you obviously have some way to propagate the same piece of
information into the kernel somehow during boot time.

For example, via a device tree property or similar.

Please pursue an avenue such as that.  This sysfs thing, it's a user
facing interface we'd have to live with forever.
