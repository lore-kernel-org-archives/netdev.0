From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 2/2] pkt_action: add new action
	skbedit
Date: Tue, 2 Sep 2008 12:27:22 +0000
Message-ID: <20080902122722.GA5040@ff.dom.local>
References: <20080830072338.7597.81426.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:29237 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbYIBM1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 08:27:33 -0400
Received: by nf-out-0910.google.com with SMTP id d3so324870nfc.21
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 05:27:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080830072338.7597.81426.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-08-2008 09:24, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This new action will have the ability to change the priority and/or
> queue_mapping fields on an sk_buff.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Two cosmetic suggestions:

Probably: include/linux/tc_act/Kbuild should be updated too.

>  include/linux/tc_act/tc_skbedit.h |   23 ++++
>  include/net/tc_act/tc_skbedit.h   |   15 +++
>  net/sched/Kconfig                 |   11 ++
>  net/sched/Makefile                |    1 
>  net/sched/act_skbedit.c           |  200 +++++++++++++++++++++++++++++++++++++
...
> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> new file mode 100644
> index 0000000..0bc4616
> --- /dev/null
> +++ b/net/sched/act_skbedit.c
...
> +#include <net/pkt_sched.h>
> +
> +#define TCA_ACT_SKBEDIT 11

Doesn't matter, but most of others (except act_simple) keep this TCA_
in include/linux/tc_act/tc_xyz.h.

Otherwise it looks OK to me.

Jarek P.
