From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 122/152] drivers/ptp/ptp_chardev.c:36
 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
Date: Sat, 03 Nov 2012 01:39:02 -0400 (EDT)
Message-ID: <20121103.013902.249179459166100599.davem@davemloft.net>
References: <20121102085915.GC2486@netboy.at.omicron.at>
	<20121102.213928.934210347094361569.davem@davemloft.net>
	<20121103045339.GA2277@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuanhan.liu@linux.intel.com, changlongx.xie@intel.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab2KCFjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 01:39:07 -0400
In-Reply-To: <20121103045339.GA2277@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 3 Nov 2012 05:53:39 +0100

> Isn't it being nicer to the memory allocation code not to repeatedly
> request small chunks?

Don't use performance as an argument against writing this code
correctly.
