From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH 2/7] net: ethernet: update drivers to handle
 HWTSTAMP_FILTER_NTP_ALL
Date: Wed, 12 Apr 2017 21:49:44 +0200
Message-ID: <20170412194944.GB10454@localhost.localdomain>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-3-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33835 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754445AbdDLTtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 15:49:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id x75so8626624wma.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 12:49:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170412141737.5881-3-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 04:17:32PM +0200, Miroslav Lichvar wrote:
> Update drivers which can timestamp all packets to handle also
> HWTSTAMP_FILTER_NTP_ALL.

The $subject and message are bit confusing, as some of those do _not_
handle ALL ...

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index a851f95..2f30b1a 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -15351,6 +15351,7 @@ int bnx2x_configure_ptp_filters(struct bnx2x *bp)
>  		break;
>  	case HWTSTAMP_FILTER_ALL:
>  	case HWTSTAMP_FILTER_SOME:
> +	case HWTSTAMP_FILTER_NTP_ALL:
>  		bp->rx_filter = HWTSTAMP_FILTER_NONE;

... like here, for example.

Thanks,
Richard
