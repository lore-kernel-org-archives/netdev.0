From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc: updated man page to reflect handle-id
 use in filter GET command.
Date: Fri, 2 Dec 2016 14:06:22 -0800
Message-ID: <20161202140622.5ecad2d6@xeon-e3>
References: <1480623644-27533-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33966 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbcLBWGZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:06:25 -0500
Received: by mail-pg0-f48.google.com with SMTP id x23so111766457pgx.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:06:25 -0800 (PST)
In-Reply-To: <1480623644-27533-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Dec 2016 15:20:44 -0500
Roman Mashak <mrv@mojatatu.com> wrote:

> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  man/man8/tc.8 | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/man/man8/tc.8 b/man/man8/tc.8
> index 8a47a2b..d957ffa 100644
> --- a/man/man8/tc.8
> +++ b/man/man8/tc.8
> @@ -32,7 +32,9 @@ class-id ] qdisc
>  DEV
>  .B [ parent
>  qdisc-id
> -.B | root ] protocol
> +.B | root ] [ handle
> +handle-id ]
> +.B protocol
>  protocol
>  .B prio
>  priority filtertype
> @@ -577,7 +579,7 @@ it is created.
>  
>  .TP
>  get
> -Displays a single filter given the interface, parent ID, priority, protocol and handle ID.
> +Displays a single filter given the interface, qdisc-id, priority, protocol and handle-id.
>  
>  .TP
>  show

The proper syntax for man page usage section is to put keywords in bold and any value
that is variable in italic.

I know this whole man page doesn't do this correctly. But that doesn't mean that new
additions should continue with the mistake.

Please revise and resubmit. Extra bonus points for fixing the other bits.
