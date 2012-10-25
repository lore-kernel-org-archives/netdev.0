From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] iplink: Added support for the kernel IPoIB
 RTNL ops
Date: Thu, 25 Oct 2012 09:02:23 -0700
Message-ID: <20121025090223.58aef233@nehalam.linuxnetplumber.net>
References: <1351177079-9052-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44260 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934896Ab2JYQDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 12:03:11 -0400
In-Reply-To: <1351177079-9052-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 16:57:59 +0200
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> Added support to ipoib rtnl ops through which one can create, configure,
> query and delete IPoIB devices, for example
> 
>  $ ip link add link ib0.8001 name ib0.8001 type ipoib pkey 0x8001
>  $ ip link add link ib0.1 name ib0.1 type ipoib mode connected
>  $ ip --details link show dev ib0.1
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied. Thanks for remembering the man page update as well.
