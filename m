From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tests: Revert back /bin/sh in shebang
Date: Mon, 16 Oct 2017 09:25:13 -0700
Message-ID: <20171016092513.36a777ec@xeon-e3>
References: <20171015095945.30878-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:45776 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754361AbdJPQZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:25:16 -0400
Received: by mail-pg0-f68.google.com with SMTP id b192so7214186pga.2
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:25:16 -0700 (PDT)
In-Reply-To: <20171015095945.30878-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Oct 2017 11:59:45 +0200
Petr Vorel <petr.vorel@gmail.com> wrote:

> This was added by mistake in commit ecd44e68
> ("tests: Remove bashisms (s/source/.)")
> 
> Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
> ---
>  testsuite/tests/ip/route/add_default_route.t | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/testsuite/tests/ip/route/add_default_route.t b/testsuite/tests/ip/route/add_default_route.t
> index 0b566f1f..569ba1f8 100755
> --- a/testsuite/tests/ip/route/add_default_route.t
> +++ b/testsuite/tests/ip/route/add_default_route.t
> @@ -1,4 +1,4 @@
> -#!/bin/bash
> +#!/bin/sh
>  
>  . lib/generic.sh
>  

Sure, applied
