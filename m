From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] i40e: fix build warnings
Date: Fri, 15 Jan 2016 17:06:22 -0800
Message-ID: <CAL3LdT52EVAxvCYWvVxKZRUMjbBf4_1gm0x0QF7FEDrKCU3++A@mail.gmail.com>
References: <1452877279.1223.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34584 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945941AbcAPBGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 20:06:23 -0500
Received: by mail-io0-f196.google.com with SMTP id k127so53196413iok.1
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 17:06:23 -0800 (PST)
In-Reply-To: <1452877279.1223.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 9:01 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Fixes following build warnings :
>
> drivers/net/ethernet/intel/i40e/i40e_main.c:7057:13: warning:
> 'i40e_sync_udp_filters_subtask' defined but not used [-Wunused-function]
> drivers/net/ethernet/intel/i40e/i40e_main.c:8524:13: warning:
> 'i40e_add_vxlan_port' defined but not used [-Wunused-function]
> drivers/net/ethernet/intel/i40e/i40e_main.c:8569:13: warning:
> 'i40e_del_vxlan_port' defined but not used [-Wunused-function]
> drivers/net/ethernet/intel/i40e/i40e_main.c:8604:13: warning:
> 'i40e_add_geneve_port' defined but not used [-Wunused-function]
> drivers/net/ethernet/intel/i40e/i40e_main.c:8651:13: warning:
> 'i40e_del_geneve_port' defined but not used [-Wunused-function]
>
> Fixes: 6a899024058d ("i40e: geneve tunnel offload support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
>

Thanks Eric, I will add this patch to my queue.
