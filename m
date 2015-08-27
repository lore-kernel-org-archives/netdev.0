From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v3 2/2] smsc911x: Ignore error return from
 device_get_phy_mode()
Date: Thu, 27 Aug 2015 14:25:06 -0700 (PDT)
Message-ID: <20150827.142506.1827996120270363660.davem@davemloft.net>
References: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
	<1440646025-18999-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rafael.j.wysocki@intel.com, jeremy.linton@arm.com, tony@atomide.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440646025-18999-2-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 26 Aug 2015 20:27:05 -0700

> Commit 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is
> configured or used") introduces an error check for the return value from
> device_get_phy_mode() and bails out if there is an error. Unfortunately,
> there are configurations where no phy is configured. Those configurations
> now fail.
> 
> To fix the problem, accept error returns from device_get_phy_mode(),
> and use the return value from device_property_read_u32() to determine
> if there is a suitable firmware interface to read the configuration.
> 
> Fixes: 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is configured or used")
> Tested-by: Tony Lindgren <tony@atomide.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
