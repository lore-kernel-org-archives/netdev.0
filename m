From: Alexander Viro <aviro@redhat.com>
Subject: Re: [PATCH] skfddi - convert to new pci model.
Date: Fri, 5 Dec 2003 18:27:21 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205232721.GA24715@devserv.devel.redhat.com>
References: <20031204163928.0f34d5d1.shemminger@osdl.org> <20031205005915.GD31510@devserv.devel.redhat.com> <20031205151249.44a067df.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Viro <aviro@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031205151249.44a067df.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 03:12:49PM -0800, Stephen Hemminger wrote:
> Second revision of the cleanup of skfddi driver.
>  * use new pci device bus initialization
>  * allocate network device with alloc_fddidev
>     and use dev->priv
>   * get rid of special module/non module distinctions.
> 
>   * fix error unwinds and return values on initialization
>   * call driver_init directly not via register_netdev
>   * reset internal queue count after purge
>   * get rid of h[iy]sterical comment that is no longer true

Looks sane.
