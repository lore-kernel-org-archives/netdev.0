From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RDMA will be reverted
Date: Wed, 28 Jun 2006 11:41:41 +0400
Message-ID: <20060628074140.GA20172@2ka.mipt.ru>
References: <20060628.000715.95062023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: rolandd@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:25057 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932757AbWF1HmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 03:42:03 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060628.000715.95062023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 12:07:15AM -0700, David Miller (davem@davemloft.net) wrote:
> Roland, there is no way in the world we would have let support for
> RDMA into the kernel tree had we seen and reviewed it on netdev.  I've
> discussed this with Andrew Morton, and we'd like you to please revert
> all of the RDMA code from Linus's tree immedialtely.

May I suggest to not revert it. RDMA and RDDP can be considered as
tun/tap or packet socket devices until they start to change internal
network structures. As far as I can see they do not, only use existing
like userspace can.

-- 
	Evgeniy Polyakov
