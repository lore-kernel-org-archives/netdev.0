From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 15:04:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011140454.GW23987@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net> <Pine.LNX.4.61.0410110858350.4733@portland.hansa.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cal Peake <cp@absolutedigital.net>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, David Gibson <hermes@gibson.dropbear.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410110858350.4733@portland.hansa.lan>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 09:12:03AM -0400, Pavel Roskin wrote:
> Another, more sophisticated solution would be to use union for iobase:
> 
> typedef struct hermes {
>         union {
>                 unsigned long io;
>                 void *mem;
>         } base;
>         int io_space; /* 1 if we IO-mapped IO, 0 for memory-mapped IO? */
> 	...
> }

Not needed.  Use ioread*/iowrite* family; it does what you need.

Al, putting together a patchset and documention on that sort of cleanups...
