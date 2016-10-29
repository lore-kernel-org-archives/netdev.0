From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RDS v1] rds: debug messages are enabled by default
Date: Sat, 29 Oct 2016 15:56:15 -0400 (EDT)
Message-ID: <20161029.155615.1198550241119215937.davem@davemloft.net>
References: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com
To: shamir.rabinovitch@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753086AbcJ2T4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:56:17 -0400
In-Reply-To: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shamir.rabinovitch@oracle.com
Date: Thu, 27 Oct 2016 05:46:38 -0400

> From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> 
> rds use Kconfig option called "RDS_DEBUG" to enable rds debug messages.
> This option cause the rds Makefile to add -DDEBUG to the rds gcc command
> line.
> 
> When CONFIG_DYNAMIC_DEBUG is enabled, the "DEBUG" macro is used by
> include/linux/dynamic_debug.h to decide if dynamic debug prints should
> be sent by default to the kernel log.
> 
> rds should not enable this macro for production builds. rds dynamic
> debug work as expected follow this fix.
> 
> Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>

Applied.
