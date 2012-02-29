From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/8] validate MAC address before call
 .ndo_set_mac_address
Date: Wed, 29 Feb 2012 15:58:59 +0000
Message-ID: <1330531139.8460.192.camel@deadeye>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Jon Mason <jdmason@kudzu.us>, Danny Kukawka <dkukawka@suse.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Kosina <jkosina@suse.cz>, Jiri Pirko <jpirko@redhat.com>,
	Joe Perches <joe@perches.com>,
	John Crispin <blogic@openwrt.org>,
	<linux-kernel@vger.kernel.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Neil Horman <nhorman@tuxdriver.com>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Hemming
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-29 at 16:42 +0100, Danny Kukawka wrote:
> Validate the given MAC address directly in dev_set_mac_address()
> if a .ndo_validate_addr function is available before calling
> the .ndo_set_mac_address function.
> 
> Changed .ndo_validate_addr to take a second parameter containing
> a sockaddr struct to be checked instead of the net_device dev_addr.
> The behaviour of .ndo_validate_addr is now: if the second parameter
> is NULL the net_device->dev_addr gets validate, if != NULL
> the given parameter/sockaddr gets validated instead.
> 
> This patch series include adaptations for some drivers which
> use .ndo_set_mac_address functions directly - to prevent double
> checks and to enable validations via .ndo_validate_addr.
[...]

You have to do this as a single patch.  The kernel and drivers should
still build at each stage.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
