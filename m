From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression on each kernel release from  2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 09:48:32 +0800
Message-ID: <1219024112.25608.321.camel@ymzhang>
References: <48A086B6.2000901@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:59271 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751291AbYHRBtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:49:23 -0400
In-Reply-To: <48A086B6.2000901@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-08-11 at 13:36 -0500, Christoph Lameter wrote:
> It seems that the network stack becomes slower over time? Here is a list of
> tbench results with various kernel versions:
> 
> 2.6.22		3207.77 mb/sec
> 2.6.24		3185.66
> 2.6.25		2848.83
> 2.6.26		2706.09
> 2.6.27(rc2)	2571.03
What's the hardware configuration? Is it dual-core?

I also track tbench performance with lastest kernels on a couple of quad-core machines,
and didn't find such regression while the results did have fluctuation.

What's the commandline you is using to start tbench? I start tbench with CPU_NUM*2.

BTW, I enabled CONFIG_SLUB since 2.6.22.

> 
> And linux-next is:
> 
> 2.6.28(l-next)	2568.74
> 
> It shows that there is still have work to be done on linux-next. Too close to
> upstream in performance.
> 
> Note the KT event between 2.6.24 and 2.6.25. Why is that?


