From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 2/2] Update documented default values for various
 TCP/UDP tunables
Date: Tue, 5 Jul 2011 09:21:47 -0400
Message-ID: <20110705132147.GB2959@hmsreliant.think-freely.org>
References: <20110705015729.91CD5815DBB1@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48065 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186Ab1GENV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:21:57 -0400
Content-Disposition: inline
In-Reply-To: <20110705015729.91CD5815DBB1@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 05:18:13PM +1000, Max Matveev wrote:
> tcp_rmem and tcp_wmem use 1 page as default value for the minimum
> amount of memory to be used, same as udp_wmem_min and udp_rmem_min.
> Pages are different size on different architectures - use the right
> units when describing the defaults.
> 
> Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Max Matveev <makc@redhat.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index ce09f83..940a404 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -394,7 +394,7 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
>  	min: Minimal size of receive buffer used by TCP sockets.
>  	It is guaranteed to each TCP socket, even under moderate memory
>  	pressure.
> -	Default: 8K
> +	Default: 1 page
>  
>  	default: initial size of receive buffer used by TCP sockets.
>  	This value overrides net.core.rmem_default used by other protocols.
> @@ -483,7 +483,7 @@ tcp_window_scaling - BOOLEAN
>  tcp_wmem - vector of 3 INTEGERs: min, default, max
>  	min: Amount of memory reserved for send buffers for TCP sockets.
>  	Each TCP socket has rights to use it due to fact of its birth.
> -	Default: 4K
> +	Default: 1 page
>  
>  	default: initial size of send buffer used by TCP sockets.  This
>  	value overrides net.core.wmem_default used by other protocols.
> @@ -553,13 +553,13 @@ udp_rmem_min - INTEGER
>  	Minimal size of receive buffer used by UDP sockets in moderation.
>  	Each UDP socket is able to use the size for receiving data, even if
>  	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
> -	Default: 4096
> +	Default: 1 page
>  
>  udp_wmem_min - INTEGER
>  	Minimal size of send buffer used by UDP sockets in moderation.
>  	Each UDP socket is able to use the size for sending data, even if
>  	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
> -	Default: 4096
> +	Default: 1 page
>  
>  CIPSOv4 Variables:
Acked-by: Neil Horman <nhorman@tuxdriver.com>

