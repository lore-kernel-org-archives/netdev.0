From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Wed, 8 Jan 2014 13:18:39 +0200
Message-ID: <52CD340F.8000903@mellanox.com>
References: <1389099678.15032.19.camel@x41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:53886 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755075AbaAHLSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 06:18:46 -0500
In-Reply-To: <1389099678.15032.19.camel@x41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2014 15:01, Paul Bolle wrote:
> Building resource_tracker.o triggers a GCC warning:
>      drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_HW2SW_CQ_wrapper':
>      drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3019:16: warning: 'cq' may be used uninitialized in this function [-Wmaybe-uninitialized]
>        atomic_dec(&cq->mtt->ref_count);
>                      ^
>
> This is a false positive. But a cleanup of cq_res_start_move_to() can
> help GCC here. The code currently uses a switch statement where a plain
> if/else would do, since only two of the switch's four cases can ever
> occur. Dropping that switch makes the warning go away.
>
> While we're at it, do some coding style cleanups (missing braces), and
> drop a test that always evaluates to true.
>

Hi Paul,

Our maintainer of that area of the code (SRIOV resource tracker) is busy 
now, but we will definitely look on these two patches in the coming 
days, thanks for posting them!
