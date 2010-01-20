From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: linux-next: Tree for January 19 (vhost_net)
Date: Wed, 20 Jan 2010 12:16:44 +0200
Message-ID: <20100120101643.GA22706@redhat.com>
References: <20100119181041.ab55f645.sfr@canb.auug.org.au> <20100119104139.2ec9164b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100119104139.2ec9164b.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 19, 2010 at 10:41:39AM -0800, Randy Dunlap wrote:
> On Tue, 19 Jan 2010 18:10:41 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20100118:
> 
> 
> When CONFIG_TUN is not enabled:
> 
> drivers/built-in.o: In function `get_socket':
> net.c:(.text+0x2899a3): undefined reference to `tun_get_socket'
> 
> 
> so VHOST_NET can either depend on TUN or select TUN, but if it
> selects TUN, it will also need to select CRC32.
> 
> ---
> ~Randy

Oh, I fixed this already but then I lost the patch:
http://lkml.org/lkml/2009/11/10/137

Sorry about that, I'll repost the fix immediately.

-- 
MST
