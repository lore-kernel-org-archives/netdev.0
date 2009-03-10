From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 03/25] [net] BUG to BUG_ON changes
Date: Tue, 10 Mar 2009 12:54:33 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1E7589DC@orsmsx507.amr.corp.intel.com>
References: <1236661850-8237-1-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-2-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-3-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stoyan Gaydarov <stoyboyker@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29717 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097AbZCJTyh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 15:54:37 -0400
In-Reply-To: <1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stoyan Gaydarov wrote:
> Signed-off-by: Stoyan Gaydarov <stoyboyker@gmail.com>
> ---
>  drivers/net/atl1e/atl1e_main.c    |    3 +--
>  drivers/net/chelsio/sge.c         |    3 +--
>  drivers/net/ixgb/ixgb_osdep.h     |    2 +-
>  drivers/net/pppol2tp.c            |    3 +--
>  drivers/net/wireless/ath9k/core.h |    6 +-----
>  5 files changed, 5 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_osdep.h
> b/drivers/net/ixgb/ixgb_osdep.h 
> index d92e72b..371a6be 100644
> --- a/drivers/net/ixgb/ixgb_osdep.h
> +++ b/drivers/net/ixgb/ixgb_osdep.h
> @@ -40,7 +40,7 @@
>  #include <linux/sched.h>
> 
>  #undef ASSERT
> -#define ASSERT(x)	if (!(x)) BUG()
> +#define ASSERT(x)	BUG_ON(!(x))
>  #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
> 
>  #ifdef DBG

ack the ixgb portion

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
