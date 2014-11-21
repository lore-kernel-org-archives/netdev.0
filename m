From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net] openvswitch: Don't validate IPv6 label masks.
Date: Fri, 21 Nov 2014 14:47:10 -0500 (EST)
Message-ID: <20141121.144710.1431540256452223326.davem@davemloft.net>
References: <1416434089-47062-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pshelar@nicira.com, dev@openvswitch.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416434089-47062-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Wed, 19 Nov 2014 13:54:49 -0800

> When userspace doesn't provide a mask, OVS datapath generates a fully
> unwildcarded mask for the flow by copying the flow and setting all bits
> in all fields. For IPv6 label, this creates a mask that matches on the
> upper 12 bits, causing the following error:
> 
> openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff, max=fffff)
> 
> This patch ignores the label validation check for masks, avoiding this
> error.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v3: Alternative approach.
>     Was "openvswitch: Fix mask generation for IPv6 labels."
> v2: OR lower 20 bits (upper 12 bits remain from earlier memdup)

Applied.
