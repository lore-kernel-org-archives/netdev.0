From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 -next 3/5] {f,m}_bpf: allow for user-defined
 object pinnings
Date: Fri, 27 Nov 2015 17:26:49 -0700
Message-ID: <5658F4C9.8090104@cumulusnetworks.com>
References: <cover.1448541097.git.daniel@iogearbox.net>
 <7011752f729c16ef154b25753448365399a26793.1448541097.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34589 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbbK1A0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 19:26:53 -0500
Received: by padhx2 with SMTP id hx2so126009892pad.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 16:26:52 -0800 (PST)
In-Reply-To: <7011752f729c16ef154b25753448365399a26793.1448541097.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/15 5:58 AM, Daniel Borkmann wrote:
> diff --git a/include/utils.h b/include/utils.h
> index 5902a98..e830be6 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -40,6 +40,10 @@ extern bool do_all;
>   #define IPSEC_PROTO_ANY	255
>   #endif
>
> +#ifndef CONFDIR
> +#define CONFDIR		"/etc/iproute2"
> +#endif
> +
>   #define SPRINT_BSIZE 64
>   #define SPRINT_BUF(x)	char x[SPRINT_BSIZE]
>
> diff --git a/lib/rt_names.c b/lib/rt_names.c
> index e87c65d..3968c76 100644
> --- a/lib/rt_names.c
> +++ b/lib/rt_names.c
> @@ -22,10 +22,7 @@
>   #include <linux/rtnetlink.h>
>
>   #include "rt_names.h"
> -
> -#ifndef CONFDIR
> -#define CONFDIR "/etc/iproute2"
> -#endif
> +#include "utils.h"
>
>   #define NAME_MAX_LEN 512
>

seems like an unrelated change.
