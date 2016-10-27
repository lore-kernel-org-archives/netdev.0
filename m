From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH RDS v1] rds: debug messages are enabled by default
Date: Thu, 27 Oct 2016 08:42:57 -0700
Message-ID: <0bf7a825-eb55-134b-a27e-10c4b8af3892@oracle.com>
References: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: shamir.rabinovitch@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25532 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbcJ0PoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:44:04 -0400
In-Reply-To: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2016 2:46 AM, shamir.rabinovitch@oracle.com wrote:
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
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
