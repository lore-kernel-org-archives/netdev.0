From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 4/4] ehea: Kconfig and Makefile
Date: Wed, 7 Jun 2006 10:59:57 -0700
Message-ID: <20060607105957.fbc92d05.rdunlap@xenotime.net>
References: <4487077B.4020405@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, meder@de.ibm.com, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:23984 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751175AbWFGR5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 13:57:10 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 10:57:08 -0700
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <4487077B.4020405@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Jun 2006 19:06:03 +0200 Jan-Bernd Themann wrote:

> Signed-off-by:  Jan-Bernd Themann <themann@de.ibm.com>
> 
> 
> drivers/net/ehea/Kconfig  |    6 ++++++
> drivers/net/ehea/Makefile |   45 +++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 51 insertions(+)
> 
> 
> 
> --- linux-2.6.16-rc5-orig/drivers/net/ehea/Makefile    1969-12-31 16:00:00.000000000 -0800
> +++ kernel/drivers/net/ehea/Makefile    2006-06-07 07:01:14.634178704 -0700
> @@ -0,0 +1,45 @@
> +# Server eHEA ethernet device driver for Linux on POWER
> +#
> +#
> +#  linux/drivers/net/ehea/Makefile
> +#
> +#  eHEA ethernet device driver for IBM eServer System p
> +#
> +#  (C) Copyright IBM Corp. 2006
> +#
> +#  Authors:
> +#       Christoph Raisch <raisch@de.ibm.com>
> +#       Jan-Bernd Themann <themann@de.ibm.com>
> +#       Heiko-Joerg Schick <schickhj@de.ibm.com>
> +#       Thomas Klein <tklein@de.ibm.com>
> +#
> +#
> +# This program is free software; you can redistribute it and/or modify
> +# it under the terms of the GNU General Public License as published by
> +# the Free Software Foundation; either version 2, or (at your option)
> +# any later version.
> +#
> +# This program is distributed in the hope that it will be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software
> +# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> +
> +
> +
> +
> +# To compile module type:
> +# make -C /root/linux-2.6.5-7.244 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m
> +# make -C /usr/src/linux-2.6.17-rc5 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m
> +
> +ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
> +
> +obj-$(CONFIG_EHEA) += ehea_mod.o
> +
> +#CFLAGS += -Werror
> +
> +
> +

45 lines for a 5-line makefile.  :(

You need to integrate the Makefile and Kconfig into the upper-level
directory Makefile and Kconfig files.  Don't expect/require people
to enter thing like this:
> +# make -C /root/linux-2.6.5-7.244 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m
> +# make -C /usr/src/linux-2.6.17-rc5 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m


> --- linux-2.6.16-rc5-orig/drivers/net/ehea/Kconfig    1969-12-31 16:00:00.000000000 -0800
> +++ kernel/drivers/net/ehea/Kconfig    2006-06-07 07:01:14.637178248 -0700
> @@ -0,0 +1,6 @@
> +config EHEA
> +       tristate "eHEA Ethernet support"
> +       depends on IBMEBUS
> +       ---help---
> +       This driver supports the IBM pSeries
> +       Ethernet adapter

That last sentence can be on one line, please.

---
~Randy
