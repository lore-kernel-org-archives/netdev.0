From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCHES] via-velocity fixes
Date: Mon, 13 Sep 2004 02:03:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41453830.9060708@pobox.com>
References: <20040913050255.GA32549@home-tj.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tejun Heo <tj@home-tj.org>
In-Reply-To: <20040913050255.GA32549@home-tj.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
>  Hello, I've encountered some problems (packet loss, duplicate
> truncated packets, hang) w/ recent rd ring related updates to
> via-veolcity.  I'm attaching 8 patches to fix the problem and some
> other bugs.  I'm attaching the following 8 patches.  Detailed
> description is at the head of each patch file.
> 
> 00velocity_nics.patch		: velocity_nics management fix
> 01velocity_xmit_lock.patch	: unused xmit_lock removed
> 02velocity_give_rx_desc.patch	: give_rx_desc removed
> 03velocity_rd_ring.patch	: rd ring fix (it was the offending bug)
> 04velocity_init.patch		: init related bug fix
> 05velocity_cpu_to_le32.patch	: removes cpu_to_le32(OWNED_BY_NIC)
> 06velocity_init_td_ring.patch	: init_td_ring index calculation fix
> 07velocity_comment.patch	: comment fixes


I'm reviewing these now, thanks.

	Jeff
