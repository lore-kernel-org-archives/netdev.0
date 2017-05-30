From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH V6 net-next iproute] ip: Add support for netdev events to
 monitor
Date: Tue, 30 May 2017 08:22:31 -0600
Message-ID: <65d65f35-5991-7131-66f3-7998914db92f@gmail.com>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
 <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36574 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdE3OWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:22:33 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so18195070pfb.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 07:22:32 -0700 (PDT)
In-Reply-To: <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/17 8:14 AM, Vladislav Yasevich wrote:
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index b8d9c7d..c6e7413 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -753,6 +753,24 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
>  	return 0;
>  }
>  
> +static const char *netdev_events[] = {"NONE",

I would prefer ifla_events rather than netdev just to reinforce the
separation that an IFLA_EVENT does not necessarily correspond to a
NETDEV event.
