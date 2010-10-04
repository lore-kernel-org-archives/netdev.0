From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2]
 drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl-checkpatch-fixes
Date: Sun, 03 Oct 2010 22:00:43 -0700 (PDT)
Message-ID: <20101003.220043.39188941.davem@davemloft.net>
References: <201010012117.o91LHCJt021158@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.j.rosenberg@gmail.com,
	grundler@parisc-linux.org, jeffm@suse.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751813Ab0JDFAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:00:22 -0400
In-Reply-To: <201010012117.o91LHCJt021158@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 01 Oct 2010 14:17:12 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> ERROR: trailing statements should be on next line
> #23: FILE: drivers/net/tulip/de4x5.c:5477:
> +	if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAULT;
> 
> total: 1 errors, 0 warnings, 8 lines checked
> 
> ./patches/drivers-net-tulip-de4x5c-fix-copy-length-in-de4x5_ioctl.patch has style problems, please review.  If any of these errors
> are false positives report them to the maintainer, see
> CHECKPATCH in MAINTAINERS.
> 
> Please run checkpatch prior to sending patches
> 
> Cc: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>
> Cc: Jeff Mahoney <jeffm@suse.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
