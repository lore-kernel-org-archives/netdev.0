From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: add 64-bit dependency
Date: Sat, 30 May 2015 23:39:06 -0700 (PDT)
Message-ID: <20150530.233906.1834698625091975461.davem@davemloft.net>
References: <5799754.oCDa9qX0W8@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, mjc@semihalf.com,
	david.daney@cavium.com, ganapatrao.kulkarni@caviumnetworks.com,
	aleksey.makarov@caviumnetworks.com, tomasz.nowicki@linaro.org,
	rrichter@cavium.com, kamil@semihalf.com,
	tsrinivasulu@caviumnetworks.com, svangala@cavium.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbbEaGjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:39:07 -0400
In-Reply-To: <5799754.oCDa9qX0W8@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 28 May 2015 16:00:46 +0200

> The thunderx ethernet driver fails to build on architectures
> that do not have an atomic readq() and writeq() function for
> 64-bit PCI bus access:
> 
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c: In function 'bgx_reg_read':
> include/asm-generic/io.h:195:23: error: implicit declaration of function 'readq' [-Werror=implicit-function-declaration]
> 
> It seems impossible to get this driver to work on most 32-bit
> hardware, so it's better to add an explicit dependency, in
> order to let us keep building 'allmodconfig' kernels on
> all architectures.
> 
> As the driver is meant for the internal hardware on an arm64 SoC, this
> is not a problem for usability. Allowing the build on all 64-bit
> architectures rather than just CONFIG_ARM64 on the other hand means that
> we get the benefit of build testing on x86.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
