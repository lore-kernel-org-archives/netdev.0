From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [2.6.19 PATCH 7/7] ehea: Makefile & Kconfig
Date: Mon, 21 Aug 2006 14:16:47 +0200
Message-ID: <44E9A42F.3000900@de.ibm.com>
References: <200608181337.44153.ossthema@de.ibm.com> <20060818141847.GE5201@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:45694 "EHLO
	mtagate2.de.ibm.com") by vger.kernel.org with ESMTP
	id S1030406AbWHUMQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 08:16:50 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060818141847.GE5201@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
 > On Fri, Aug 18, 2006 at 01:37:44PM +0200, Jan-Bernd Themann wrote:
 >> --- linux-2.6.18-rc4/drivers/net/Kconfig
 >> +++ patched_kernel/drivers/net/Kconfig
 >> @@ -2277,6 +2277,12 @@ config CHELSIO_T1
 >>            To compile this driver as a module, choose M here: the module
 >>            will be called cxgb.
 >>
 >> +config EHEA
 >> +        tristate "eHEA Ethernet support"
 >> +        depends on IBMEBUS
 >> +        ---help---
 >> +          This driver supports the IBM pSeries ethernet adapter
 >                                                                 .
 >
 > People usually add the following boilerplate:
 >
 >       To compile this driver as a module, choose M here: the module
 >       will be called $FOO.

Agreed.
