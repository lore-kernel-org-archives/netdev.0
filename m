From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Packet timestamps (was: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20)
Date: Tue, 6 Mar 2007 15:38:44 +0100
Message-ID: <200703061538.45049.dada1@cosmosbay.com>
References: <200609181850.22851.ak@suse.de> <4514147D.5040803@hp.com> <20070306132551.GB8412@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andi Kleen <ak@suse.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39661 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965879AbXCFOir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:38:47 -0500
In-Reply-To: <20070306132551.GB8412@tentacle.sectorb.msk.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 14:25, Vladimir B. Savkin wrote:

>  	},
> +	{
> +		.ctl_name	= NET_CORE_ACCURATE_TIMESTAMPS,
> +		.procname	= "accurate_timestamps",
> +		.data		= &sysctl_accurate_timestamps,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec
> +	},
>  	{ .ctl_name = 0 }
>  };
>
>
> May I ask about integrating this or a similar solution for those
> like me who values routing performance (with bind9 running) over
> minor convinience of having tcpdump always display accurate
> timestamps?
>

Quite frankly I dont like this patch :

1) Fix applications, do not bloat kernel.

2) "accurate_timestamps" is misleading. 
	Should be "disable_timestamps" 

