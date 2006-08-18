From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [2.6.19 PATCH 7/7] ehea: Makefile & Kconfig
Date: Fri, 18 Aug 2006 18:18:47 +0400
Message-ID: <20060818141847.GE5201@martell.zuzino.mipt.ru>
References: <200608181337.44153.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:45239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030417AbWHROSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:18:55 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1292105nfa
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 07:18:54 -0700 (PDT)
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608181337.44153.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2006 at 01:37:44PM +0200, Jan-Bernd Themann wrote:
> --- linux-2.6.18-rc4/drivers/net/Kconfig
> +++ patched_kernel/drivers/net/Kconfig
> @@ -2277,6 +2277,12 @@ config CHELSIO_T1
>            To compile this driver as a module, choose M here: the module
>            will be called cxgb.
>
> +config EHEA
> +        tristate "eHEA Ethernet support"
> +        depends on IBMEBUS
> +        ---help---
> +          This driver supports the IBM pSeries ethernet adapter
								  .

People usually add the following boilerplate:

	To compile this driver as a module, choose M here: the module
	will be called $FOO.

