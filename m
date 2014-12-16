From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] tun/macvtap: TUNSETIFF fixes
Date: Tue, 16 Dec 2014 11:20:21 -0500 (EST)
Message-ID: <20141216.112021.1488501911448698827.davem@davemloft.net>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com, jasowang@redhat.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 16 Dec 2014 15:04:53 +0200

> Dan Carpenter reported the following:
 ...
> And that's true: we have run out of IFF flags in tun.
> 
> So let's not try to add more: add simple GET/SET ioctls
> instead. Easy to test, leads to clear semantics.
> 
> Alternatively we'll have to revert the whole thing for 3.19,
> but that seems more work as this has dependencies
> in other places.
> 
> While here, I noticed that macvtap was actually reading
> ifreq flags as a 32 bit field.
> Fix that up as well.

Looks good, series applied, thanks.
