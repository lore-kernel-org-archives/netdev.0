From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET] 64 bit byte counter for 2.6.3
Date: Wed, 18 Feb 2004 18:17:59 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4033F2A7.70404@pobox.com>
References: <1077123078.9223.7.camel@midux>	<20040218101711.25dda791@dell_ss3.pdx.osdl.net>	<Pine.LNX.4.53.0402181527000.7318@chaos>	<1077137014.18843.10.camel@midux>	<Pine.LNX.4.53.0402181645220.27707@chaos> <20040218145740.6b47c218@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: root@chaos.analogic.com,
	=?ISO-8859-1?Q?Markus_H=E4stbacka?= <midian@ihme.org>,
	Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040218145740.6b47c218@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Do it right:
> 	* use per-cpu long long for both bytes and packet counts
> 	  and change each driver ...
> 	* expose both a new 64 bit and legacy 32 bit /proc interface
> 	* no tools use /sys yet, so that needs to show long long
> 	* have both a get_stats and get_stats64 hook in netdevice so not all drivers
> 	  have to be converted at once.


Yep.

	Jeff
