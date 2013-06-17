From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 01/16] tipc: update code comments to reflect
 new uapi header path
Date: Mon, 17 Jun 2013 21:33:25 +0400
Message-ID: <51BF4865.2000005@cogentembedded.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com> <1371480891-5264-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:63738 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab3FQRd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 13:33:29 -0400
Received: by mail-lb0-f173.google.com with SMTP id v1so2786605lbd.32
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 10:33:27 -0700 (PDT)
In-Reply-To: <1371480891-5264-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/17/2013 06:54 PM, Paul Gortmaker wrote:

> From: Ying Xue <ying.xue@windriver.com>

> Files tipc.h and tipc_config.h were moved to uapi directory, but
> the corresponding comments were not updated at the same time.

> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>   include/uapi/linux/tipc.h        | 2 +-
>   include/uapi/linux/tipc_config.h | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)

> diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
> index f2d9009..852373d 100644
> --- a/include/uapi/linux/tipc.h
> +++ b/include/uapi/linux/tipc.h
> @@ -1,5 +1,5 @@
>   /*
> - * include/linux/tipc.h: Include file for TIPC socket interface
> + * include/uapi/linux/tipc.h: Header for TIPC socket interface
>    *
>    * Copyright (c) 2003-2006, Ericsson AB
>    * Copyright (c) 2005, 2010-2011, Wind River Systems
> diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
> index 0b1e3f2..6b0bff0 100644
> --- a/include/uapi/linux/tipc_config.h
> +++ b/include/uapi/linux/tipc_config.h
> @@ -1,5 +1,5 @@
>   /*
> - * include/linux/tipc_config.h: Include file for TIPC configuration interface
> + * include/uapi/linux/tipc_config.h: Header for TIPC configuration interface

    File names in the heading comments are generally frowned upon. Maybe 
it's worth just removing them?

WBR, Sergei
