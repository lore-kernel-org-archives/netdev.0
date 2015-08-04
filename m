From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Mon, 3 Aug 2015 22:31:58 -0700
Message-ID: <20150803223158.40ae7d52@urahara>
References: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
To: Richard Laing <richard.laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35517 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbHDFbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:31:50 -0400
Received: by pasy3 with SMTP id y3so31578581pas.2
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:31:50 -0700 (PDT)
In-Reply-To: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Aug 2015 13:28:47 +1200
Richard Laing <richard.laing@alliedtelesis.co.nz> wrote:

> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 5fa643b..7db9f72 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -117,6 +117,8 @@ struct fib_info {
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>  	int			fib_power;
>  #endif
> +	/* Cache the number of live nexthops for flow based ECMP calculation. */
> +	int			live_nexthops;

unsigned or u16 ? rather than risking sign issues.
