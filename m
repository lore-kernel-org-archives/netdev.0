From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] netpoll: fix netconsole IPv6 setup
Date: Thu, 6 Feb 2014 12:34:10 -0800
Message-ID: <CAHA+R7OQYZ5RLn3v0nucKB=CVpDCZqp=HyNL=qgC9bViVKEuAQ@mail.gmail.com>
References: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:37018 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbaBFUeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 15:34:12 -0500
Received: by mail-la0-f47.google.com with SMTP id hr17so1884350lab.20
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 12:34:11 -0800 (PST)
In-Reply-To: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 9:34 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>  net/core/netpoll.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index c03f3de..a664f78 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -948,6 +948,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
>  {
>         char *cur=opt, *delim;
>         int ipv6;
> +       bool ipversion_set = false;
>

Or initialize 'ipv6' to -1 and then check if it is -1?
