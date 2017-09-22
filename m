From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] man: fix documentation for range of route
 table ID
Date: Fri, 22 Sep 2017 10:09:50 -0700
Message-ID: <20170922100950.6c476012@xeon-e3>
References: <20170921182647.GB30364@orbyte.nwl.cc>
        <20170922112854.21289-1-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:52303 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdIVRJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 13:09:52 -0400
Received: by mail-pg0-f45.google.com with SMTP id i195so902893pgd.9
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 10:09:52 -0700 (PDT)
In-Reply-To: <20170922112854.21289-1-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Sep 2017 13:28:54 +0200
Thomas Haller <thaller@redhat.com> wrote:

> Signed-off-by: Thomas Haller <thaller@redhat.com>
> ---
> Changes in v2:
>   - "0" is not a valid table ID.
> 
>  man/man8/ip-route.8.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
> index 803de3b9..705ceb20 100644
> --- a/man/man8/ip-route.8.in
> +++ b/man/man8/ip-route.8.in
> @@ -322,7 +322,7 @@ normal routing tables.
>  .P
>  .B Route tables:
>  Linux-2.x can pack routes into several routing tables identified
> -by a number in the range from 1 to 2^31 or by name from the file
> +by a number in the range from 1 to 2^32-1 or by name from the file
>  .B @SYSCONFDIR@/rt_tables
>  By default all normal routes are inserted into the
>  .B main

Applied
