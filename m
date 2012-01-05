From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 5 Jan 2012 14:39:33 -0800
Message-ID: <20120105223933.GA10268@kroah.com>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gwingerde@gmail.com,
	larry.finger@lwfinger.net, davem@davemloft.net,
	bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325796541-11402-1-git-send-email-festevam@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2012 at 06:49:01PM -0200, Fabio Estevam wrote:
> MISC_DEVICES option alone does not select any kernel code and can cause dependency build warnings, such as:
> 
> warning: (KS8851 && AX88796_93CX6 && RTL8180 && RTL8187 && ADM8211 && RT2400PCI && RT2500PCI && RT61PCI && RT2800PCI && R8187SE) selects EEPROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)
> 
> Remove MISC_DEVICES option so that any dependency on this symbol is avoided.

Are you sure that this isn't getting confused with the
drivers/char/misc.c interface instead of the "throw a bunch of randome
drivers into drivers/misc/" issue?

Why would anything ever want to select MISC_DEVICES?  What happens if
you just remove that select line from the Kconfig?

thanks,

greg k-h
