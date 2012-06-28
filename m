From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [patch net-next 0/4] net: introduce and use
 IFF_LIFE_ADDR_CHANGE
Date: Thu, 28 Jun 2012 17:15:07 +0200
Message-ID: <20120628151507.GA5920@localhost.localdomain>
References: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, rusty@rustcorp.com.au,
	mst@redhat.com, virtualization@lists.linux-foundation.org,
	edumazet@google.com, danny.kukawka@bisect.de,
	shimoda.hiroaki@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:42129 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab2F1PPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 11:15:19 -0400
Received: by wgbds11 with SMTP id ds11so220100wgb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 08:15:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 28, 2012 at 04:10:35PM +0200, Jiri Pirko wrote:
> three drivers updated, but this can be used in many others.
> 
> Jiri Pirko (4):
>   net: introduce new priv_flag indicating iface capable of change mac
>     when running
>   virtio_net: use IFF_LIFE_ADDR_CHANGE priv_flag
>   team: use IFF_LIFE_ADDR_CHANGE priv_flag
>   dummy: use IFF_LIFE_ADDR_CHANGE priv_flag

I think you must mean LIVE and not LIFE...

Thanks,
Richard


> 
>  drivers/net/dummy.c      |   15 ++-------------
>  drivers/net/team/team.c  |    9 +++++----
>  drivers/net/virtio_net.c |   11 +++++------
>  include/linux/if.h       |    2 ++
>  net/ethernet/eth.c       |    2 +-
>  5 files changed, 15 insertions(+), 24 deletions(-)
> 
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
