From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/15] ehea: Update multiqueue support
Date: Wed, 11 May 2011 19:31:04 -0700
Message-ID: <1305167464.6124.9.camel@Joe-Laptop>
References: <20110512005213.897432612@samba.org>
	 <20110512005622.681433781@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1497 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab1ELCbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 22:31:05 -0400
In-Reply-To: <20110512005622.681433781@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> The ehea driver had some multiqueue support but was missing the last
> few years of networking stack improvements:

Hi Anton, all comments to follow on all patches are trivia only...
[]
> Signed-off-by: Anton Blanchard <anton@samba.org>
[]
> +++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:49.640116670 +1000
[]
> @@ -93,7 +93,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of
>  MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
>  		 "[2^x - 1], x = [6..14]. Default = "
>  		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
> -MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
> +MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");

trailing space
 
> +++ linux-net/drivers/net/ehea/ehea_ethtool.c	2011-05-12 07:47:49.640116670 +1000
> @@ -189,7 +189,6 @@ static char ehea_ethtool_stats_keys[][ET

static const?



