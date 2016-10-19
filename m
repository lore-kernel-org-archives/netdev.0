From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net] rtnetlink: Add rtnexthop offload flag to compare mask
Date: Tue, 18 Oct 2016 22:26:03 -0400
Message-ID: <CAHashqADC-8qsYC0puUruV2sCQp-5SUXm7bMAUJQZ3pUEJZPbg@mail.gmail.com>
References: <1476809974-14707-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz <ogerlitz@mellanox.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        nikolay@cumulusnetworks.com,
        "John W. Linville" <linville@tuxdriver.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        dsa@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, nicolas.dichtel@6wind.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35329 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753508AbcJSC0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 22:26:24 -0400
Received: by mail-qk0-f195.google.com with SMTP id v138so882364qka.2
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 19:26:24 -0700 (PDT)
In-Reply-To: <1476809974-14707-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 12:59 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> The offload flag is a status flag and should not be used by
> FIB semantics for comparison.

This is definitely needed.

>
> Fixes: 37ed9493699c ("rtnetlink: add RTNH_F_EXTERNAL flag for fib offload")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Andy Gospodarek <andy@greyhouse.net>

> ---
> Please queue-up to stable as well. Thanks.
> ---
>  include/uapi/linux/rtnetlink.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 262f037..5a78be5 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -350,7 +350,7 @@ struct rtnexthop {
>  #define RTNH_F_OFFLOAD         8       /* offloaded route */
>  #define RTNH_F_LINKDOWN                16      /* carrier-down on nexthop */
>
> -#define RTNH_COMPARE_MASK      (RTNH_F_DEAD | RTNH_F_LINKDOWN)
> +#define RTNH_COMPARE_MASK      (RTNH_F_DEAD | RTNH_F_LINKDOWN | RTNH_F_OFFLOAD)
>
>  /* Macros to handle hexthops */
>
> --
> 2.5.5
>
