From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [iproute2 json PATCH] ip: ipaddress: fix missing space after prefixlen
Date: Wed, 20 Sep 2017 13:13:17 -0700
Message-ID: <CAM_1_KzOAK+SDrnL12SGxkdcc3LB-TM6b13RKs+ZRtjNgDMjFw@mail.gmail.com>
References: <20170920200421.94514-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, sd@queasysnail.net,
        Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:56811 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdITUNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:13:39 -0400
Received: by mail-io0-f175.google.com with SMTP id m103so6214497iod.13
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 13:13:39 -0700 (PDT)
In-Reply-To: <20170920200421.94514-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry Sabrina, looks like i forgot the reported-by tag, i'll send a v2...

On Wed, Sep 20, 2017 at 1:04 PM, Julien Fortin
<julien@cumulusnetworks.com> wrote:
> From: Julien Fortin <julien@cumulusnetworks.com>
>
> Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
>
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
> ---
>  ip/ipaddress.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 97971450..fb496bbb 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1604,7 +1604,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
>                                            format_host_rta(ifa->ifa_family,
>                                                            rta_tb[IFA_ADDRESS]));
>                 }
> -               print_int(PRINT_ANY, "prefixlen", "/%d", ifa->ifa_prefixlen);
> +               print_int(PRINT_ANY, "prefixlen", "/%d ", ifa->ifa_prefixlen);
>         }
>
>         if (brief)
> --
> 2.14.1
>
