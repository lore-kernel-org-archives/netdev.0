From: Pavel Roskin <proski@gnu.org>
Subject: Re: linux/802_11.h header
Date: Tue, 30 Mar 2004 19:15:07 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403301908280.8794@marabou.research.att.com>
References: <Pine.LNX.4.58.0403301514080.7498@marabou.research.att.com>
 <20040330215128.GA13891@bougret.hpl.hp.com> <Pine.LNX.4.58.0403301820001.8684@marabou.research.att.com>
 <20040330233934.GA16711@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040330233934.GA16711@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Mar 2004, Jean Tourrilhes wrote:

> > Because my question is not why atmel_cs uses a header it doesn't need
> > (the answer would be likely "oops" or "just in case").
> >
> > My question is why we have two headers for the same purpose in the
> > kernel and what are we going to do with the header that is not used.
>
> 	At some point, we had the headers of the old aironet4500 driver
> which looked like this one, but I don't think this driver was ever moved
> to the wireless directory, so this is why I think this file was added
> with the Atmel driver.

Right.  aironet4500 included linux/802_11.h.  Since aironet4500 was
removed in 2.6 kernels, linux/802_11.h should also be removed.  I really
don't want anybody to find this file and use definitions from it rather
than from ieee802_11.h.

The patch has been sent to Simon.

By the way, ieee802_11.h could be "promoted" to include/linux or
include/net with trivial changes to the drivers that use it.

-- 
Regards,
Pavel Roskin
