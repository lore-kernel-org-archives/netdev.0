From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] Fix Linux priority and band for TOS==0x2
 (man 8 tc-prio)
Date: Fri, 9 May 2014 13:30:38 -0700
Message-ID: <20140509133038.6647d26b@nehalam.linuxnetplumber.net>
References: <1399663362-23054-1-git-send-email-sergey@lobanov.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Sergey V. Lobanov" <sergey@lobanov.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36602 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249AbaEIUal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:30:41 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so4094414pdi.7
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 13:30:41 -0700 (PDT)
In-Reply-To: <1399663362-23054-1-git-send-email-sergey@lobanov.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 May 2014 23:22:42 +0400
"Sergey V. Lobanov" <sergey@lobanov.in> wrote:

> Due to commit 4a2b9c3(in Linux kernel) Linux priority(skb->priority)
> changed for TOS==0x2
> 
> Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>
> ---
>  man/man8/tc-prio.8 |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
> index 1625fcc..78694ea 100644
> --- a/man/man8/tc-prio.8
> +++ b/man/man8/tc-prio.8
> @@ -106,7 +106,7 @@ see in the first column of this table:
>  TOS     Bits  Means                    Linux Priority    Band
>  ------------------------------------------------------------
>  0x0     0     Normal Service           0 Best Effort     1
> -0x2     1     Minimize Monetary Cost   1 Filler          2
> +0x2     1     Minimize Monetary Cost   0 Best Effort     1
>  0x4     2     Maximize Reliability     0 Best Effort     1
>  0x6     3     mmc+mr                   0 Best Effort     1
>  0x8     4     Maximize Throughput      2 Bulk            2

Applied
