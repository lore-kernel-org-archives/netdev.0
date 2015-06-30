From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3.10.y 0/2] ipv6: avoid soft lockups in fib6_run_gc()
Date: Mon, 29 Jun 2015 17:28:51 -0700
Message-ID: <20150630002851.GE6430@kroah.com>
References: <20150610103926.3791.22866.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150610103926.3791.22866.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 10, 2015 at 01:40:42PM +0300, Konstantin Khlebnikov wrote:
> Two patches from 3.11 which are missing in 3.10.y
> 
> I've just seen livelock in 3.10.69+ where all cpus are stuck in fib6_run_gc()

As David doesn't queue up network patches for 3.10-stable anymore (and I
don't blame him), I've added these myself to the tree.

thanks,

greg k-h
