From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 00/16] Mellanox 100G SRIOV E-Switch offload
 and VF representors
Date: Fri, 1 Jul 2016 14:04:04 +0300
Message-ID: <CALzJLG_98jBdK62B=bN4=C8xdEL4zp2=mZOMOfJGv_n+JXNNGA@mail.gmail.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com> <20160701.061639.58539315378533703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, gospo@cumulusnetworks.com,
	jesse.brandeburg@intel.com,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34356 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcGALJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 07:09:43 -0400
Received: by mail-qk0-f180.google.com with SMTP id t127so195311852qkf.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 04:09:43 -0700 (PDT)
In-Reply-To: <20160701.061639.58539315378533703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 1:16 PM, David Miller <davem@davemloft.net> wrote:
>
> So you have submitted to me, in parallel, two non-trivial sets of changes
> to the mlx5 driver.  One for 'net' and one for 'net-next, and at the same
> exact time.
>
> You haven't given me any indication of whether there are any dependencies
> nor conflicts from these two sets of changes.
>

Right,

Now that i see you've merged 'f5074d0ce2f8 Merge branch
'mlx5-100G-fixes'' ino net-next

the last patch "net/mlx5e: Introduce SRIOV VF representors" will
encounter the following compilation error

drivers/net/ethernet/mellanox/mlx5/core/en_rep.c: In function
'mlx5e_rep_get_strings':
drivers/net/ethernet/mellanox/mlx5/core/en_rep.c:68:31: error: 'const
struct counter_desc' has no member named 'name'
           sw_rep_stats_desc[i].name);

I will rebase, fix and respin.

Regarding the latest fixes you applied today ''resiliency and xmit
path fixes", there will be two trivial conflicts (not related to this
series) once net is merged into net-next.

I will send you details on that mail thread.
