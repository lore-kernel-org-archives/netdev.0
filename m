From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next:master 122/152] drivers/ptp/ptp_chardev.c:36
 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
Date: Fri, 2 Nov 2012 09:59:15 +0100
Message-ID: <20121102085915.GC2486@netboy.at.omicron.at>
References: <509326ff.Rs30l/1GTlOl9dW+%yuanhan.liu@linux.intel.com>
 <20121102020631.GI16883@yliu-dev.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: changlongx.xie@intel.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50310 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab2KBI7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 04:59:24 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1687107eek.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 01:59:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121102020631.GI16883@yliu-dev.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 02, 2012 at 10:06:31AM +0800, Yuanhan Liu wrote:
> 
> Hi Richard,
> 
> _just_ FYI and let you aware of it, there are new smatch warnings show up in
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   b77bc2069d1e437d5a1a71bb5cfcf4556ee40015
> commit: 215b13dd288c2e1e4461c1530a801f5f83e8cd90 [122/152] ptp: add an ioctl to compare PHC time with system time
> 
> + drivers/ptp/ptp_chardev.c:36 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
>   drivers/ptp/ptp_chardev.c:144 ptp_read() warn: 'event' puts 960 bytes on stack

I am aware that these methods use large stack buffers, but I thought
it was okay seeing as they are both under the 1k limit.

Thanks,
Richard
