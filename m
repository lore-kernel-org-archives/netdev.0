From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] net: doc: add default value for neighbour
 parameters
Date: Thu, 6 Dec 2012 01:43:55 +0000
Message-ID: <1354758235.17107.131.camel@deadeye.wl.decadent.org.uk>
References: <50BED29B.4050805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50725 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab2LFBoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 20:44:05 -0500
In-Reply-To: <50BED29B.4050805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 12:50 +0800, Shan Wei wrote:
> From: Shan Wei <davidshan@tencent.com>
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index c6d5fee..0462a71 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -30,16 +30,24 @@ neigh/default/gc_thresh3 - INTEGER
>  	Maximum number of neighbor entries allowed.  Increase this
>  	when using large numbers of interfaces and when communicating
>  	with large numbers of directly-connected peers.
> +	Default: 1024
>  
>  neigh/default/unres_qlen_bytes - INTEGER
>  	The maximum number of bytes which may be used by packets
>  	queued for each	unresolved address by other network layers.
>  	(added in linux 3.3)
> +	Seting negative value is meaningless and will retrun error.
> +	Default: 65536 Bytes(64KB)
>  
>  neigh/default/unres_qlen - INTEGER
>  	The maximum number of packets which may be queued for each
>  	unresolved address by other network layers.
>  	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
> +	Prior to linux 3.3, the default value is 3 which may cause
> +	secluded packet loss. The current default value is calculated
          ^^^^^^^^
I think the proper word here is 'silent'?

> +	according to default value of unres_qlen_bytes and true size of
> +	packet.
> +	Default: 31
>  
>  mtu_expires - INTEGER
>  	Time, in seconds, that cached PMTU information is kept.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
