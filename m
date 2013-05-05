From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio: don't expose u16 in userspace api
Date: Sun, 05 May 2013 16:58:25 -0400 (EDT)
Message-ID: <20130505.165825.1787385657172692387.davem@davemloft.net>
References: <20130503174941.043d10b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akong@redhat.com
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130503174941.043d10b7@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 3 May 2013 17:49:41 -0700

> Programs using virtio headers outside of kernel will no longer
> build because u16 type does not exist in userspace. All user ABI
> must use __u16 typedef instead.
> 
> Bug introduce by:
>   commit 986a4f4d452dec004697f667439d27c3fda9c928
>   Author: Jason Wang <jasowang@redhat.com>
>   Date:   Fri Dec 7 07:04:56 2012 +0000
> 
>     virtio_net: multiqueue support
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable.
