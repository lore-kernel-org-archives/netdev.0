From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] pedit: do not print debugging information by
 default
Date: Mon, 10 Feb 2014 14:44:17 -0800
Message-ID: <20140210144417.3f7bcec4@nehalam.linuxnetplumber.net>
References: <1391037179-3510-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:58238 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbaBJWoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:44:20 -0500
Received: by mail-pb0-f45.google.com with SMTP id un15so6883687pbc.32
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:44:20 -0800 (PST)
In-Reply-To: <1391037179-3510-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jan 2014 15:12:59 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---
> diff --git a/tc/m_pedit.c b/tc/m_pedit.c
> index 452d96f..16dd277 100644
> --- a/tc/m_pedit.c
> +++ b/tc/m_pedit.c
> @@ -30,7 +30,7 @@
>  #include "m_pedit.h"
>  
>  static struct m_pedit_util *pedit_list;
> -int pedit_debug = 1;
> +static int pedit_debug;
>  
>  static void
>  explain(void)

Applied
