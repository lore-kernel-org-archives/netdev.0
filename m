From: "David Schwartz" <davids@webmaster.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 13:16:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <WorldClient-F200409151316.AA16360002@webmaster.com>
References: <4148991B.9050200@pobox.com> <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Reply-To: davids@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: "David Stevens" <dlstevens@us.ibm.com>, "Netdev" <netdev@oss.sgi.com>,
        leonid.grossman@s2io.com,
        "Linux Kernel" <linux-kernel@vger.kernel.org>
In-Reply-To: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David Stevens wrote:

> I've never understood why people are so interested in off-loading
> networking. Isn't that just a multi-processor system where you can't
> use any of the network processor cycles for anything else? And, of
> course, to be cheap, the network processor will be slower, and much
> harder to debug and update software.

The issues of debugging the network processor software and maintaining it is 
certainly a legitimate one. However, nothing stops you from using the extra 
network processor cycles for other purposes.

> If the PCI bus is too slow, or MTU's too small, wouldn't
> it be better to fix those directly and use a fast host processor that
> can
> also do other things when not needed for networking? And why have
> memory on a NIC that can't be used by other things?

This isn't an either-or. Processors are cheap. Memory is cheap.
 
> Why don't we off-load filesystems to disks instead?  Or a graphics
> card that implements X ? :-) I'd rather have shared system resources--
> more flexible. :-)

It's not one or the other. If, for example, your network card, graphics 
card, and hard drive controller all use a common instruction set and are all 
interconnected by a fast bus, code can be fairly mobile and run wherever 
it's the most efficient. Nothing stops the OS from offloading internal tasks 
to these processors as well.

The only real stumbling blocks have been cost/volume considerations and the 
fact that the central processor(s) can be so fast, and the I/O so slow in 
comparison, that there's not much to gain.

DS
