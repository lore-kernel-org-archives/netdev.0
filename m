From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [NET 02/06]: Introduce RTA_TABLE/FRA_TABLE attributes
Date: Fri, 11 Aug 2006 11:02:43 +0400
Message-ID: <44DC2B93.3000605@tls.msk.ru>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain> <20060810193000.14867.49807.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:13391 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1161149AbWHKHCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 03:02:50 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20060810193000.14867.49807.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h

> +static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
> +{
> +	return RTA_GET_U32(rta[RTA_TABLE-1]);
> +rtattr_failure:
> +	return table;
> +}
> +

What's that ?  ;)

/mjt
