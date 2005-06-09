From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 12:56:19 +0200
Message-ID: <20050609105619.GH3169@elf.ucw.cz>
References: <20050608142310.GA2339@elf.ucw.cz> <42A723D3.3060001@linux.intel.com> <20050608212707.GA2535@elf.ucw.cz> <42A76719.2060700@linux.intel.com> <20050608223437.GB2614@elf.ucw.cz> <1118287990.10234.114.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Netdev list <netdev@oss.sgi.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262344AbVFIK4j@vger.kernel.org>
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <1118287990.10234.114.camel@debian.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > Actually it would still transmit when user did not want it to. I
> > believe that staying "quiet" is right thing, long-term. And it could
> > solve firmware-loading problems, short-term...
> 
> If ipw2100 is built into kernel, you can disable it by kernel parameter
> ipw2100.disable=1. Then you can enable it with:
> 
> $ echo 0 > /sys/bus/pci/drivers/ipw2100/*/rf_kill
> 
> > How long does association with AP take? Anyway it should be easy to
> > tell driver to associate ASAP, just after the insmod...
> 
> Are you suggesting by default it is disabled for built into kernel but
> enabled as a module?

I'm suggesting that by default it is disabled (in kernel or as a
module) and its automatically enabled during ifconfig up.

That way we can drop the kernel parameter and always do the right
thing.

								Pavel
