From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 3/3] ip: sysctl documentation cleanup
Date: Tue, 1 Jul 2008 15:55:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807011549340.26330@shark.he.net>
References: <20080701153820.235faa72@extreme> <20080701153926.7b3fe1dd@extreme>
 <20080701154306.21b04c75@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:45657 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755062AbYGAWzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:55:16 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 1 Jul 2008 15:55:05 -0700
In-Reply-To: <20080701154306.21b04c75@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Tue, 1 Jul 2008, Stephen Hemminger wrote:

> Fix some documentation stuff:
>   * replace non-standard spelling
>   * remove confusing sentence in F-RTO description. The existing
>     text is sufficient to explain what the option does
>   * reorganize and update list of undocumented values
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/Documentation/networking/ip-sysctl.txt	2008-07-01 14:52:00.000000000 -0700
> +++ b/Documentation/networking/ip-sysctl.txt	2008-07-01 15:12:26.000000000 -0700
> @@ -159,7 +159,7 @@ tcp_congestion_control - STRING
>  	Default is set as part of kernel configuration.
>  
>  tcp_dsack - BOOLEAN
> -	Allows TCP to send "duplicate" SACKs.
> +	Allows TCP to send "duplicate" SACK's.

I think that either way is OK for these...

>  
>  tcp_ecn - BOOLEAN
>  	Enable Explicit Congestion Notification in TCP.
> @@ -185,10 +185,9 @@ tcp_frto - INTEGER
>  	timeouts.  It is particularly beneficial in wireless environments
>  	where packet loss is typically due to random radio interference
>  	rather than intermediate router congestion.  F-RTO is sender-side
> -	only modification.  Therefore it does not require any support from
> -	the peer, but in a typical case, however, where wireless link is
> -	the local access link and most of the data flows downlink, the
> -	faraway servers should have F-RTO enabled to take advantage of it.
> +	only modification therefore it does not require any support from
> +	the peer.

Run-on sentence :(

> +
>  	If set to 1, basic version is enabled.  2 enables SACK enhanced
>  	F-RTO if flow uses SACK.  The basic version can be used also when
>  	SACK is in use though scenario(s) with it exists where F-RTO
> @@ -270,13 +269,13 @@ tcp_mem - vector of 3 INTEGERs: min, pre
>  	pressure mode, which is exited when memory consumption falls
>  	under "min".
>  
> -	max: number of pages allowed for queueing by all TCP sockets.
> +	max: number of pages allowed for queuing by all TCP sockets.

google for "queuing theory" has about 198,000 hits.
google for "queueing theory" has about 499,000 hits.

grep kernel source tree for "queuing" has 487 hits.
grep kernel source tree for "queueing" has 728 hits.

I wouldn't change this.

>  
>  	Defaults are calculated at boot time from amount of available
>  	memory.
>  
>  tcp_moderate_rcvbuf - BOOLEAN
> -	If set, TCP performs receive buffer autotuning, attempting to
> +	If set, TCP performs receive buffer auto tuning, attempting to

or auto-tuning?  :)

>  	automatically size the buffer (no greater than tcp_rmem[2]) to
>  	match the size required by the path for full throughput.  Enabled by
>  	default.

-- 
~Randy
