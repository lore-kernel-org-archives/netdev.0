From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix mask generation for IPv6 labels.
Date: Wed, 19 Nov 2014 15:19:48 -0500 (EST)
Message-ID: <20141119.151948.1499529626052606712.davem@davemloft.net>
References: <1416336857-61405-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pshelar@nicira.com, dev@openvswitch.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416336857-61405-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Tue, 18 Nov 2014 10:54:17 -0800

> When userspace doesn't provide a mask, OVS datapath generates a fully
> unwildcarded mask for the flow. This is done by taking a copy of the
> flow key, then iterating across its attributes, setting all values to
> 0xff. This works for most attributes, as the length of the netlink
> attribute typically matches the length of the value. However, IPv6
> labels only use the lower 20 bits of the field. This patch makes a
> special case to handle this.
> 
> This fixes the following error seen when installing IPv6 flows without a mask:
> 
> openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff, max=fffff)
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Judging by the discussion ongoing about this patch, I am assuming there
will be a new version of this change forthcoming.

Thanks.
