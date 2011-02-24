From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/2] dcbnl: add support for retrieving
 peer configuration - ieee
Date: Thu, 24 Feb 2011 19:42:39 +0000
Message-ID: <1298576559.2613.40.camel@bwh-desktop>
References: <1298581410.8877.21.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, John Fastabend <john.r.fastabend@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39400 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907Ab1BXTmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 14:42:43 -0500
In-Reply-To: <1298581410.8877.21.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-24 at 23:03 +0200, Shmulik Ravid wrote:
> These 2 patches add the support for retrieving the remote or peer DCBX
> configuration via dcbnl for embedded DCBX stacks. The peer configuration
> is part of the DCBX MIB and is useful for debugging and diagnostics of
> the overall DCB configuration. The first patch add this support for IEEE
> 802.1Qaz standard the second patch add the same support for the older
> CEE standard. 
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> ---
>  include/linux/dcbnl.h |   38 ++++++++++++++++++++++++++
>  include/net/dcbnl.h   |    5 +++
>  net/dcb/dcbnl.c       |   71 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 114 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
> index 4c5b26e..3102185 100644
> --- a/include/linux/dcbnl.h
> +++ b/include/linux/dcbnl.h
> @@ -110,6 +110,22 @@ struct dcb_app {
>  	__u16	protocol;
>  };
>  
> +/* This structure contains the APP feature information sent by the peer.
> + * It is used for both the IEEE 802.1Qaz and the CEE flavors.
> + *
> + * @willing: willing bit in the peer APP tlv
> + * @error: error bit in the peer APP tlv
> + * @app_count: The number of objects in the peer APP table.
[...]

It looks like this was supposed to be a kernel-doc comment, but it's not
valid as such unless you start with:

    /**
     * struct dcb_peer_app_info - one-line description here

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

