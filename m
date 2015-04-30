From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Fix unaligned accesses
Date: Thu, 30 Apr 2015 16:26:50 -0400 (EDT)
Message-ID: <20150430.162650.1003471084725529367.davem@davemloft.net>
References: <1430340771-12425-1-git-send-email-david.ahern@oracle.com>
	<CAJ3xEMhrSDXhGgQbV=EGJ_TcJfJE3=44Ad_daKmDpcQwnuxkpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.ahern@oracle.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbbD3U0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:26:52 -0400
In-Reply-To: <CAJ3xEMhrSDXhGgQbV=EGJ_TcJfJE3=44Ad_daKmDpcQwnuxkpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Thu, 30 Apr 2015 16:26:42 +0300

> On Wed, Apr 29, 2015 at 11:52 PM, David Ahern <david.ahern@oracle.com> wrote:
>> Addresses the following kernel logs seen during boot:
>>
>> Kernel unaligned access at TPC[100ee150] mlx4_QUERY_HCA+0x80/0x248 [mlx4_core]
>> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
>> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
>> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
>> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
>>
>> Signed-off-by: David Ahern <david.ahern@oracle.com>
> 
> Looks OK
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
