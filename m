From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: next-20150323 build: 1 failures 23 warnings (next-20150323)
Date: Mon, 23 Mar 2015 23:08:07 +0100
Message-ID: <20150323220806.GB8891@linux-mips.org>
References: <E1YZyoN-00019n-50@debutante>
 <20150323212524.GU14954@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:43457 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbCWWIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:08:13 -0400
Received: from localhost.localdomain ([127.0.0.1]:42600 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27009710AbbCWWIKqq7py (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Mar 2015 23:08:10 +0100
Content-Disposition: inline
In-Reply-To: <20150323212524.GU14954@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 02:25:24PM -0700, Mark Brown wrote:

> On Mon, Mar 23, 2015 at 09:38:19AM +0000, Build bot for Mark Brown wrote:
> 
> In current -next the bgmac driver does not compile in an ARM
> allmodconfig:
> 
> > 	arm-allmodconfig
> > ../drivers/net/ethernet/broadcom/bgmac.c:20:27: fatal error: bcm47xx_nvram.h: No such file or directory
> 
> because this include file is only present on MIPS.  This looks at first
> glance to have happened in the merge commit edb15d83a875a1f4 from the
> MIPS tree though I think that needs a bit more investigation.

At that time the bgmac NIC was still exclusivly used on MIPS.

  Ralf
