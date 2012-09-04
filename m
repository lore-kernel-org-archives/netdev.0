From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 2/2] iplink: added support for ipoib rtnl link
 ops
Date: Tue, 4 Sep 2012 10:48:41 -0700
Message-ID: <20120904104841.3e9f848b@nehalam.linuxnetplumber.net>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
	<1345724119-32110-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55592 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954Ab2IDRtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 13:49:09 -0400
In-Reply-To: <1345724119-32110-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 15:15:19 +0300
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> Added basic support to create/delete IPoIB child devices,
> where the user can optionally specify the IB PKEY (Partition Key)
> to be used by the newly created device. If nothing is provided,
> the child will use the same pkey as the parent.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

This is a good way to manage the child devices.
But I am holding off merging it into iproute2 until after the
kernel parts are final (in Linus's tree).  Please resubmit
after the kernel parts are merged.
