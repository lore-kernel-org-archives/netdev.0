From: Shannon Nelson <shannon.lee.nelson@gmail.com>
Subject: Re: [RFC PATCH 05/12] net: Create and use new helper xfrm_dst_child().
Date: Wed, 25 Oct 2017 08:56:06 -0700
Message-ID: <CAP-MU4M7qeOdSDorZvFyH9BxvXZEFupftmKnV+pWpMQEyLpwHg@mail.gmail.com>
References: <20171025.230325.1201318483362616226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:56730 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdJYP4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 11:56:08 -0400
Received: by mail-vk0-f67.google.com with SMTP id g11so293843vkd.13
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 08:56:07 -0700 (PDT)
In-Reply-To: <20171025.230325.1201318483362616226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 7:03 AM, David Miller <davem@davemloft.net> wrote:
>
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index f002a2c5e33c..4fa951112873 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -994,6 +994,15 @@ struct xfrm_dst {
>  };
>
>  #ifdef CONFIG_XFRM

Perhaps the new xfrm_dst_child() code needs to go before this #ifdef?
sln

>
> +static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
> +{
> +#ifdef CONFIG_XFRM
> +       if (dst->xfrm)
> +               return dst->child;
> +#endif
> +       return NULL;
> +}
> +


-- 
==============================================
Mr. Shannon Nelson         Parents can't afford to be squeamish.
