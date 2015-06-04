From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 6/6] ipvlan: Call ILA in incoming and outgoing
 receive paths
Date: Thu, 4 Jun 2015 10:58:48 +0200
Message-ID: <20150604085848.GA20040@pox.localdomain>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
 <1433361502-3478761-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, agartrell@fb.com, maheshb@google.com,
	netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36429 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbbFDI6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:58:51 -0400
Received: by wgbgq6 with SMTP id gq6so28228563wgb.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 01:58:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433361502-3478761-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/15 at 12:58pm, Tom Herbert wrote:
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 1acc283..e029fad 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -9,6 +9,10 @@
>  
>  #include "ipvlan.h"
>  
> +bool query_ila = false;
> +module_param(query_ila, bool, 0644);
> +MODULE_PARM_DESC(query_ila, "Query ILA in incoming and outgoing paths");

Can we make this not a module param?
