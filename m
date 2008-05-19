From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 19 May 2008 17:24:06 +0100
Message-ID: <1211214246.24946.47.camel@pc1117.cambridge.arm.com>
References: <20080515170728.GA3176@PTXN0038.genpitfi01.og.ge.com>
	 <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael.Hennerich@analog.com, Enrik.Berkhan@ge.com,
	hennerich@blackfin.uclinux.org, ian.saturley@smsc.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	Bill Gatliff <bgat@billgatliff.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:45831 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754079AbYESQXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 12:23:01 -0400
In-Reply-To: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-19 at 13:34 +0100, Steve Glendinning wrote:
> Attached is a driver for SMSC's LAN911x and LAN921x families of embedded
> ethernet controllers.
[...]
>  drivers/net/Kconfig    |   13 +
>  drivers/net/Makefile   |    1 +
>  drivers/net/smsc911x.c | 2285 ++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/smsc911x.h |  389 ++++++++

Maybe you should patch the MAINTAINERS file as well since it's not clear
from the file header who is maintaining it.

> --- /dev/null
> +++ b/drivers/net/smsc911x.h
[...]
> +/* platform_device configuration data, should be assigned to
> + * the platform_device's dev.platform_data */
> +struct smsc911x_platform_config {
> +	unsigned int irq_polarity;
> +	unsigned int irq_type;
> +};

BTW, how could this structure be used in the platform specific code
(arch/arm/mach-*/* in my case)? This header file cannot be included
since it is not under the include/ directory and redefining the
structure for each platform is prone to errors (and too much
duplication). I can see other drivers place a header file (maybe only
containing the structure definition) in include/linux/ or include/asm-*/
(the latter if it is specific to only one architecture which I don't
think it is the case here). 

-- 
Catalin

