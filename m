From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 1/4] net: add name_assign_type netdev attribute
Date: Fri, 11 Jul 2014 12:23:01 -0700 (PDT)
Message-ID: <20140711.122301.94365507620163228.davem@davemloft.net>
References: <1405026066-2547-1-git-send-email-teg@jklm.no>
	<1405026066-2547-2-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dh.herrmann@gmail.com, kay@vrfy.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405026066-2547-2-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Thu, 10 Jul 2014 23:01:03 +0200

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 30eedf6..392c784 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6438,11 +6438,12 @@ void netdev_freemem(struct net_device *dev)
>  
>  /**
>   *	alloc_netdev_mqs - allocate network device
> - *	@sizeof_priv:	size of private data to allocate space for
> - *	@name:		device name format string
> - *	@setup:		callback to initialize device
> - *	@txqs:		the number of TX subqueues to allocate
> - *	@rxqs:		the number of RX subqueues to allocate
> + *	@sizeof_priv:		size of private data to allocate space for
> + *	@name:			device name format string
> + *	@name_assign_type: 	origin of device name
> + *	@setup:			callback to initialize device
> + *	@txqs:			the number of TX subqueues to allocate
> + *	@rxqs:			the number of RX subqueues to allocate
>   *
>   *	Allocates a struct net_device with private data area for driver use
>   *	and performs basic initialization.  Also allocates subqueue structs

This belongs in patch #3, where you actually change the arguments to
this interface, not here.
