From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2] ip: increase number of MPLS labels
Date: Sat, 29 Apr 2017 23:04:30 -0700
Message-ID: <20170429230430.702c6b72@xeon-e3>
References: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33179 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936332AbdD3GEc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 02:04:32 -0400
Received: by mail-pf0-f177.google.com with SMTP id q20so10696182pfg.0
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 23:04:32 -0700 (PDT)
In-Reply-To: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Apr 2017 20:48:50 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Kernel now supports more than 2 labels. Increase ip to
> handle up to 16 labels.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/utils.h | 8 ++++----
>  lib/utils.c     | 2 +-
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/utils.h b/include/utils.h
> index 8c12e1e2a60c..a69e176c260d 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -54,6 +54,9 @@ void incomplete_command(void) __attribute__((noreturn));
>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
>  #define PREV_ARG() do { argv--; argc++; } while(0)
>  
> +/* Maximum number of labels the mpls helpers support */
> +#define MPLS_MAX_LABELS 16
> +

Why is the kernel limit not in include/uapi/ header file?
