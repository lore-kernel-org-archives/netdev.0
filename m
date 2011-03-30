From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/usb: Ethernet quirks for the LG-VL600 4G modem
Date: Wed, 30 Mar 2011 02:36:09 -0700 (PDT)
Message-ID: <20110330.023609.91338968.davem@davemloft.net>
References: <1301263473-27849-1-git-send-email-andrew.zaborowski@intel.com>
	<1301352993-21535-1-git-send-email-andrew.zaborowski@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name,
	dbrownell@users.sourceforge.net, linux-kernel@vger.kernel.org,
	balrogg@gmail.com
To: andrew.zaborowski@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301352993-21535-1-git-send-email-andrew.zaborowski@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Date: Tue, 29 Mar 2011 00:56:33 +0200

> This adds a driver for the CDC Ethernet part of this modem.  The
> device's ID is blacklisted in cdc_ether.c and is white-listed in
> this new driver because of the quirks needed to make it useful.
> The modem's firmware exposes a CDC ACM port for modem control and a
> CDC Ethernet port for network data.  The descriptors look fine but
> both ports actually are some sort of multiplexers requiring non-
> standard headers added/removed from every packet or they get
> ignored.  All information is based on a usb traffic log from a
> Windows machine.
> 
> On the Verizon 4G network I've seen speeds up to 1.1MB/s so far with
> this driver, a speed-o-meter site reports 16.2Mbps/10.5Mbps.
> Userspace scripts are required to talk to the CDC ACM port.
> 
> Signed-off-by: Andrzej Zaborowski <balrogg@gmail.com>

Applied, thanks.
