From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and
 net.sctp.sctp_wmem tunables
Date: Mon, 04 Jul 2011 17:11:57 +0100
Message-ID: <1309795917.2729.0.camel@bwh-desktop>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30484 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab1GDQMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 12:12:01 -0400
In-Reply-To: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 18:08 +1000, Max Matveev wrote:
> sctp does not use second and third ("default" and "max") values
> of sctp_(r|w)mem tunables. The format is the same and tcp_(r|w)mem
> but the meaning is different so make the documentation explicit to
> avoid confusion.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index d3d653a..f37d374 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1465,10 +1465,17 @@ sctp_mem - vector of 3 INTEGERs: min, pressure, max
>  	Default is calculated at boot time from amount of available memory.
>  
>  sctp_rmem - vector of 3 INTEGERs: min, default, max
> -	See tcp_rmem for a description.
> +	Only the first value ("min") is used, "default" and "max" are
> +	ignored and may be removed in the future versions.
> +
> +	min: Minimal size of receive buffer used by SCTP socket.
> +	It is guaranteed to each STCP socket (but not association) even 

Typo: 'STCP' should be 'SCTP'.

Ben.

> +	under moderate memory pressure.
> +
> +	Default: 1 page
>  
>  sctp_wmem  - vector of 3 INTEGERs: min, default, max
> -	See tcp_wmem for a description.
> +	Currently this tunable has no effect.
>  
>  addr_scope_policy - INTEGER
>  	Control IPv4 address scoping - draft-stewart-tsvwg-sctp-ipv4-00

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

