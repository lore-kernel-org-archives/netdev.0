From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] missing statics in atm
Date: Sun, 15 Aug 2004 19:18:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815191847.3d242356.davem@redhat.com>
References: <20040814143324.GA26061@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040814143324.GA26061@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 16:33:24 +0200
Christoph Hellwig <hch@lst.de> wrote:

> -struct net_device *clip_devs = NULL;
> -struct atm_vcc *atmarpd = NULL;
> +static struct net_device *clip_devs;
> +static struct atm_vcc *atmarpd;
 ...
> -
> -extern struct net_device *clip_devs;
> -

Works for me.  Patch applied, thanks Christoph.
