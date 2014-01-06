From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] isdn: Drop big endian cpp checks from telespci and
 hfc_pci drivers
Date: Mon, 06 Jan 2014 15:51:16 -0500 (EST)
Message-ID: <20140106.155116.2301761686285996039.davem@davemloft.net>
References: <1388982699-11514-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388982699-11514-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun,  5 Jan 2014 20:31:39 -0800

> With arm:allmodconfig, building the Teles PCI driver fails with
> 
> telespci.c:294:2: error: #error "not running on big endian machines now"
> 
> Similar, building the driver for HFC PCI-Bus cards fails with
> 
> hfc_pci.c:1647:2: error: #error "not running on big endian machines now"
> 
> Remove the big endian cpp check from both drivers to fix the build errors.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thank you.
