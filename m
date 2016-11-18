From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [PATCH iproute2 1/1] tc: updated man page to reflect GET command
 to retrieve a single filter.
Date: Fri, 18 Nov 2016 14:41:28 +0530
Message-ID: <be774d83f997e19ce7c2a1d9ff0f2d1b@mail.gmail.com>
References: <1478485658-14379-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        stephen@networkplumber.org
To: Roman Mashak <mrv@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35091 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcKRJLb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 04:11:31 -0500
Received: by mail-yw0-f172.google.com with SMTP id i145so160720781ywg.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 01:11:31 -0800 (PST)
In-Reply-To: <1478485658-14379-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Roman Mashak
>
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  man/man8/tc.8 | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/man/man8/tc.8 b/man/man8/tc.8 index 4e99dca..3f4f8b5 100644
> --- a/man/man8/tc.8
> +++ b/man/man8/tc.8
> @@ -28,7 +28,7 @@ class-id ] qdisc
>
>  .B tc
>  .RI "[ " OPTIONS " ]"
> -.B filter [ add | change | replace | delete ] dev
> +.B filter [ add | change | replace | delete | get ] dev
>  DEV
>  .B [ parent
>  qdisc-id

The handle parameter seems to be missing from the TC filter syntax
synopsis ; as in:
tc [ OPTIONS ] filter [ add | change | replace | delete | get ]  dev  DEV
[
       parent  qdisc-id  | root ] protocol protocol prio priority handle
handle-ID

^^^^^^^^^^^^^

I guess the user would have to specify the handle-ID to retrieve a single
filter.

thanks,
-Sathya
