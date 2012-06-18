From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: man: Fix incorrect parameter format in prio.
Date: Mon, 18 Jun 2012 12:25:46 -0700
Message-ID: <20120618122546.21ec3267@nehalam.linuxnetplumber.net>
References: <4FDEC949.30207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37108 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700Ab2FRTZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 15:25:50 -0400
In-Reply-To: <4FDEC949.30207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jun 2012 14:23:05 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> Parameter priomap use blank instead of comma to separate bands,
> update manpage to confirms to this.
> ---
>  man/man8/tc-prio.8 |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
> index 1625fcc..55a5f3d 100644
> --- a/man/man8/tc-prio.8
> +++ b/man/man8/tc-prio.8
> @@ -11,7 +11,7 @@ major:
>  .B ] prio [ bands 
>  bands
>  .B ] [ priomap
> -band,band,band... 
> +band band band... 
>  .B ] [ estimator 
>  interval timeconstant
>  .B ]
> @@ -134,7 +134,7 @@ showing to which Priority they are mapped.
>  The last column shows the result of the default priomap. On the command line,
>  the default priomap looks like this:
>  
> -    1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
> +    1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  
>  This means that priority 4, for example, gets mapped to band number 1.
>  The priomap also allows you to list higher priorities (> 7) which do not

Applied (had to fix whitespace in patch)
