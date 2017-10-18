From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next] net: ipv4: Change fib notifiers to take a
 fib_alias
Date: Wed, 18 Oct 2017 22:26:56 +0300
Message-ID: <20171018192656.GA4520@splinter>
References: <1508351953-26442-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:63493
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751126AbdJRT1E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 15:27:04 -0400
Content-Disposition: inline
In-Reply-To: <1508351953-26442-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 11:39:13AM -0700, David Ahern wrote:
> All of the notifier data (fib_info, tos, type and table id) are
> contained in the fib_alias. Pass it to the notifier instead of
> each data separately shortening the argument list by 3.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

LGTM.

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
