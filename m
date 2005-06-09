From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 11:33:10 +0800
Message-ID: <1118287990.10234.114.camel@debian.sh.intel.com>
References: <20050608142310.GA2339@elf.ucw.cz>
	 <42A723D3.3060001@linux.intel.com> <20050608212707.GA2535@elf.ucw.cz>
	 <42A76719.2060700@linux.intel.com>  <20050608223437.GB2614@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Netdev list <netdev@oss.sgi.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261304AbVFIDgX@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050608223437.GB2614@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

On Thu, 2005-06-09 at 00:34 +0200, Pavel Machek wrote:
> Actually it would still transmit when user did not want it to. I
> believe that staying "quiet" is right thing, long-term. And it could
> solve firmware-loading problems, short-term...

If ipw2100 is built into kernel, you can disable it by kernel parameter
ipw2100.disable=1. Then you can enable it with:

$ echo 0 > /sys/bus/pci/drivers/ipw2100/*/rf_kill

> How long does association with AP take? Anyway it should be easy to
> tell driver to associate ASAP, just after the insmod...

Are you suggesting by default it is disabled for built into kernel but
enabled as a module?

Thanks,
-yi
