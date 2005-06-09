From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 12:53:24 -0700 (PDT)
Message-ID: <20050609.125324.88476545.davem@davemloft.net>
References: <200506090909.55889.vda@ilport.com.ua>
	<20050608.231657.59660080.davem@davemloft.net>
	<20050609104205.GD3169@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda@ilport.com.ua, abonilla@linuxwireless.org, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pavel@ucw.cz
In-Reply-To: <20050609104205.GD3169@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 9 Jun 2005 12:42:05 +0200

> I'm not saying it should not work automagically. But it is wrong to
> start transmitting on wireless as soon as kernel boots. It should stay
> quiet in the radio until it is either told to talk or until interface
> is upped.

I agree.

There is a similar problem in the Acenic driver, it brings the
link up and receives broadcast packets as soon as the driver
is loaded.  Mostly this is because the driver inits the chip
and registers the IRQ handler at probe time, whereas nearly
every other driver does this at ->open() time.
