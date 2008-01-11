From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 16:45:47 -0200
Message-ID: <1200077147.9349.37.camel@cafe>
References: <1199981839.8931.35.camel@cafe>
	 <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
	 <1200068444.9349.20.camel@cafe> <47879DE4.8080603@cosmosbay.com>
	 <20080111173654.M91690@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:35337 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbYAKSpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 13:45:51 -0500
Received: from mailhub3.br.ibm.com (unknown [9.18.232.110])
	by igw3.br.ibm.com (Postfix) with ESMTP id CE32C3902D2
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:37:51 -0200 (BRDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BIjnTc4051058
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:45:49 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BIjnkf011825
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:45:49 -0200
In-Reply-To: <20080111173654.M91690@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Denys, 
   I've installed sysstat (good tools!) and the result is very similar
to the one which appears at top, take a look:
   13:34:23     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
13:34:24     all    0.00    0.00    2.72    0.00    0.25   12.13    0.99   83.91  16267.33
13:34:24       0    0.00    0.00   21.78    0.00    0.00    0.00    7.92   70.30     40.59
13:34:24       1    0.00    0.00    0.00    0.00    0.99   24.75    0.00   74.26   4025.74
13:34:24       2    0.00    0.00    0.00    0.00    0.99   24.75    0.00   74.26   4036.63
13:34:24       3    0.00    0.00    0.00    0.00    0.99   21.78    0.00   77.23   4032.67
13:34:24       4    0.00    0.00    0.00    0.00    0.98   24.51    0.00   74.51   4034.65
13:34:24       5    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00     30.69
13:34:24       6    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00     33.66
13:34:24       7    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00     32.67

So, we can assure that the IRQs are not being balanced, and that there
isn't any processor overload.

Thanks!


On Fri, 2008-01-11 at 19:36 +0200, Denys Fedoryshchenko wrote:
> Maybe good idea to use sysstat ?
> 
> http://perso.wanadoo.fr/sebastien.godard/

