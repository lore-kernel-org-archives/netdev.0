From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] thermal: shorten too long mcast group name
Date: Thu, 21 Mar 2013 13:04:12 +0000
Message-ID: <20130321130412.GC9046@casper.infradead.org>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
 <1363693648-10015-3-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50013 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab3CUNEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:04:13 -0400
Content-Disposition: inline
In-Reply-To: <1363693648-10015-3-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/13 at 08:47pm, Masatake YAMATO wrote:
> The original name is too long.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---
>  include/linux/thermal.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/thermal.h b/include/linux/thermal.h
> index f0bd7f9..e3c0ae9 100644
> --- a/include/linux/thermal.h
> +++ b/include/linux/thermal.h
> @@ -44,7 +44,7 @@
>  /* Adding event notification support elements */
>  #define THERMAL_GENL_FAMILY_NAME                "thermal_event"
>  #define THERMAL_GENL_VERSION                    0x01
> -#define THERMAL_GENL_MCAST_GROUP_NAME           "thermal_mc_group"
> +#define THERMAL_GENL_MCAST_GROUP_NAME           "thermal_mc_grp"

Just saying that this would not be OK in general as this would
break any application looking up the multicast group id by name
via genetlink but since it's broken anyway right now it's OK I guess.
