From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 15:11:08 -0700 (PDT)
Message-ID: <20050609.151108.92584111.davem@davemloft.net>
References: <20050609104205.GD3169@elf.ucw.cz>
	<20050609.125324.88476545.davem@davemloft.net>
	<42A8AE2A.4080104@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, vda@ilport.com.ua, abonilla@linuxwireless.org,
	jgarzik@pobox.com, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262485AbVFIWLZ@vger.kernel.org>
To: jketreno@linux.intel.com
In-Reply-To: <42A8AE2A.4080104@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Ketrenos <jketreno@linux.intel.com>
Date: Thu, 09 Jun 2005 16:01:30 -0500

> The ipw2100 originally postponed doing any initialization until open was
> called.  The problem at that time was that distributions were crafted to
> rely on link detection (I believe via ethtoolop's get_link) before they
> would bring the interface up.

Yes, I see, and that does work for most ethernet devices.
I noticed that Debian's 3.1 installer used this to determine
which ethernet device it should use as the default in it's
network device dialogue.

One idea, returning true for get_link when the device is down, may not
be a bad idea for the wireless case.
