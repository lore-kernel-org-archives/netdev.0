From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: TOE brain dump
Date: 02 Aug 2003 21:57:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059857864.20305.14.camel@dhcp22.swansea.linux.org.uk>
References: <20030802140444.E5798@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
In-Reply-To: <20030802140444.E5798@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sad, 2003-08-02 at 18:04, Werner Almesberger wrote:
>  - last but not least, keeping TOE firmware up to date with the
>    TCP/IP stack in the mainstream kernel will require - for each
>    such TOE device - a significant and continuous effort over a
>    long period of time

or even the protocol and protocol refinements..

>  - instead of putting a different stack on the TOE, a
>    general-purpose processor (probably with some enhancements,
>    and certainly with optimized data paths) is added to the NIC

Like say an opteron in the 2nd socket on the motherboard

> Benefits:
> 
>  - putting the CPU next to the NIC keeps data paths short, and
>    allows for all kinds of optimizations (e.g. a pipelined
>    memory architecture)

It moves the cost it doesnt make it vanish

If I read you right you are arguing for a second processor running
Linux.with its own independant memory bus. AMD make those already its
called AMD64. I don't know anyone thinking at that level about
partitioning one as an I/O processor.
