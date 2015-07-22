From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 22 Jul 2015 21:57:06 +0200
Message-ID: <20150722195706.GA26717@pox.localdomain>
References: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com>
 <20150722122309.GB968@pox.localdomain>
 <20150722.104926.1502608671575195516.davem@davemloft.net>
 <55AFEF4B.6070702@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33327 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbbGVT5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 15:57:09 -0400
Received: by wicmv11 with SMTP id mv11so95589145wic.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 12:57:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55AFEF4B.6070702@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/15 at 12:30pm, roopa wrote:
> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index 5c467ef..2b28615 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -24,6 +24,8 @@ config NET_MPLS_GSO
> 
>  config MPLS_ROUTING
>         tristate "MPLS: routing support"
> +       depends on INET
> +       depends on IPV6
>         ---help---
>          Add support for forwarding of mpls packets.

This looks like a much better fix to me and resolves the
module/built-in dependency mess.
