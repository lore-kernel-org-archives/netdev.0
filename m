From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] ipw2100 v1.1.0
Date: Thu, 24 Mar 2005 10:59:59 -0800
Message-ID: <20050324185959.GA22129@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com, James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote :
> 
> I wasn't sure where to actually stick the driver's selection it in the 
> Kconfig menu.  Where its at now, it doesn't show up until you enable 
> 'Generic IEEE 80211 subsystem', and then it shows up down under Wireless 
> Lan entries.

	I personally enable the driver to be selected directly and
then SELECT the 802.11 stack, the same way you SELECT the firmware
loader. The logic is that the user doesn't really care how it's
implemented under the cover (via the 802.11 stack or not), he just
want to make his hardware work. A good example of this logic is the
Aironet driver (PCI versus Pcmcia).
	But, those are trivial matter that can be discussed and
resolved long after the driver is in the kernel, so no need to respin
your patch. Anyway, most people use distro kernels that have all
options enabled...

	Apart from that, congratulation on the excellent work...
	Have fun...

	Jean
