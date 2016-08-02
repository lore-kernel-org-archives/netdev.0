From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1083/1285] Replace numeric parameter like 0444 with
 macro
Date: Tue, 2 Aug 2016 09:27:20 -0400
Message-ID: <20160802092720.5b150b85@gandalf.local.home>
References: <20160802121455.22326-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiangshanlai@gmail.com,
	mathieu.desnoyers@efficios.com, m.chehab@samsung.com,
	gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, oleg@redhat.com,
	gang.chen.5i5j@gmail.com, mhocko@suse.com, koct9i@gmail.com,
	aarcange@redhat.com, aryabinin@virtuozzo.com
To: Baole Ni <baolex.ni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0221.hostedemail.com ([216.40.44.221]:59148 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966695AbcHBN1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 09:27:25 -0400
In-Reply-To: <20160802121455.22326-1-baolex.ni@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Aug 2016 20:14:55 +0800
Baole Ni <baolex.ni@intel.com> wrote:

> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
> 

NACK!

I find 0444 more readable than S_IRUSR | S_IRGRP | S_IROTH.

-- Steve

> Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> Signed-off-by: Baole Ni <baolex.ni@intel.com>
> ---
>  net/802/garp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/802/garp.c b/net/802/garp.c
> index b38ee6d..ecc976a 100644
> --- a/net/802/garp.c
> +++ b/net/802/garp.c
> @@ -22,7 +22,7 @@
>  #include <asm/unaligned.h>
>  
>  static unsigned int garp_join_time __read_mostly = 200;
> -module_param(garp_join_time, uint, 0644);
> +module_param(garp_join_time, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  MODULE_PARM_DESC(garp_join_time, "Join time in ms (default 200ms)");
>  MODULE_LICENSE("GPL");
>  
