From: jamal <hadi@cyberus.ca>
Subject: Re: TOE brain dump
Date: 04 Aug 2003 12:45:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060015518.1103.399.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ihar 'Philips' Filipau" <filia@softhome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Can you please post to netdev? Posting networking related issues to
linux kernel alone is considered rude. Posting them to netdev only
is acceptable.

>  Ihar 'Philips' Filipau wrote:
>
> >Werner Almesberger wrote:
> > Ihar 'Philips' Filipau wrote:
> >
> >| | |  Modern NPUs generally do this.
> >
> >
> > Unfortunately, they don't - they run *some* code, but that
> > is rarely a Linux kernel, or a substantial part of it.
> >
>
>    Embedded CPU we are using is based MIPS, and has a lot of specialized
> instructions.
>    It makes not that much sense to run kernel (especially Linux) on CPU
> which is optimized for handling of network packets. (And has actually
> several co-processors to help in this task).

The coprocessors are useful, but that has nothing to do with the value 
of the NPU. You can add those within a general processor system.
I am also in the camp that to be really useful these things need to run
a real OS - Linux.

>    How much sense it makes to run general purpose OS (optimized for PCs
> and servers) on devices which can make only couple of functions? (and no
> MMU btw)
>
>    It is a whole idea behind this kind of CPUs - to do a few of
> functions - but to do them good.
>
>    If you will start stretching CPUs like this to fit Linux kernel - it
> will generally just increase price. Probably there are some markets
> which can afford this.
>

Actually i believe it will lower the prices.I am waiting for intel to get 
hyperthreading right - then we'll see these things disapear.
The only thing useful about NPUs is their ability to management the
discrepency between memory latency and CPU speeds. Trust me i used to
be in the same camp as you.If you note, a lot of these things appeared
around the height of the .com days. VCs were looking for something
new and exciting.

>    Remeber - "Small is beatiful" (c) - and linux kernel far from it.
>    Our routing code which handles two GE interfaces (actually not pure
> GE, but up to 2.5GB) fits into 3k. 3k of code - and that's it. not 650kb
> of bzip compressed bloat. And it handles two interfaces, handles fast
> data path from siblign interfaces, handles up to 1E6 routes. 3k of code.
> not 650k of bzip.

If all you wanted was to do L3 - why not just buy a $5 chip that can do this 
for a lot more interfaces? Why sweat over optimizing L3 routing in a 
3K space? 
to nit: Its no longer about routing or bridging, friend. Thats like getting 
fries at mcdonalds.

cheers,
jamal 
