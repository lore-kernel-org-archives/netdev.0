From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 5/6] ehea: makefile
Date: Wed, 9 Aug 2006 11:50:47 +0200
Message-ID: <20060809095047.GA11555@mars.ravnborg.org>
References: <44D99F74.1000704@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:9641 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S1030623AbWHIJvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:51:07 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44D99F74.1000704@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:40:20AM +0200, Jan-Bernd Themann wrote:
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> 
>  drivers/net/ehea/Makefile |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> 
> 
> --- linux-2.6.18-rc4-orig/drivers/net/ehea/Makefile	1969-12-31 
> 16:00:00.000000000 -0800
> +++ kernel/drivers/net/ehea/Makefile	2006-08-08 23:59:38.083467216 -0700
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the eHEA ethernet device driver for IBM eServer System p
> +#
> +
> +ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o 
> ehea_phyp.o
> +obj-$(CONFIG_EHEA) += ehea_mod.o
> +

Using -objs is deprecated, please use ehea_mod-y.
This needs to be documented and later warned upon which I will do soon.

	Sam

