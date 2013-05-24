From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [ PATCH iproute2] ss: replace bfp with bpf in usage().
Date: Fri, 24 May 2013 08:11:09 -0700
Message-ID: <20130524081109.1415c97c@nehalam.linuxnetplumber.net>
References: <1369388560-6030-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:50551 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab3EXPLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 11:11:12 -0400
Received: by mail-pd0-f180.google.com with SMTP id 14so1814600pdc.25
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 08:11:12 -0700 (PDT)
In-Reply-To: <1369388560-6030-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 May 2013 12:42:40 +0300
Rami Rosen <ramirose@gmail.com> wrote:

> This patch fixes usage() of misc/ss.c to use bpf instead of bfp.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>  misc/ss.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 9f6354e..418dd6f 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2926,7 +2926,7 @@ static void _usage(FILE *dest)
>  "   -p, --processes	show process using socket\n"
>  "   -i, --info		show internal TCP information\n"
>  "   -s, --summary	show socket usage summary\n"
> -"   -b, --bfp           show bpf filter socket information\n"
> +"   -b, --bpf           show bpf filter socket information\n"
>  "\n"
>  "   -4, --ipv4          display only IP version 4 sockets\n"
>  "   -6, --ipv6          display only IP version 6 sockets\n"

applied
