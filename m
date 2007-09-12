From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/16] net: Support multiple network namespaces with
 netlink
Date: Wed, 12 Sep 2007 04:06:16 -0700 (PDT)
Message-ID: <20070912.040616.38701475.davem@davemloft.net>
References: <m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:44738
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760675AbXILLGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:06:19 -0400
In-Reply-To: <m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:28:27 -0600

> 
> Each netlink socket will live in exactly one network namespace,
> this includes the controlling kernel sockets.
> 
> This patch updates all of the existing netlink protocols
> to only support the initial network namespace.  Request
> by clients in other namespaces will get -ECONREFUSED.
> As they would if the kernel did not have the support for
> that netlink protocol compiled in.
> 
> As each netlink protocol is updated to be multiple network
> namespace safe it can register multiple kernel sockets
> to acquire a presence in the rest of the network namespaces.
> 
> The implementation in af_netlink is a simple filter implementation
> at hash table insertion and hash table look up time.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
