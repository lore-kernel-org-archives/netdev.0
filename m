From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel 2.6.13: TCP (libnet?)
Date: Wed, 31 Aug 2005 00:36:36 +0200
Message-ID: <4314DF74.1030402__36562.2135148898$1125441784$gmane$org@trash.net>
References: <20050830194107.GA11652@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John McGowan <jmcgowan@inch.com>, mike@infonexus.com
In-Reply-To: <20050830194107.GA11652@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John McGowan wrote:
> Kernel 2.6.13: TCP (libnet?)
> 
> Broken libnet?
> 
> KERNEL: linux-kernel@vger.kernel.org
> LIBNET 1.1 (c) 1998 - 2004 Mike D. Schiffman <mike@infonexus.com>
> 
> I don't like spam. I track spamvertized sites. Many only respond to TCP
> packets sent to port 80. I need a TCP traceroute (traceroute using TCP/SYN
> packets).
> 
> I have four such programmes.
> 
> 1: Hping in traceroute mode.
>    Poor. If it hits a router which does not respond, it just sits
>    and waits.
> 2: LFT
>    OK.
>    a: Does not work in Fedora Core2 - without patching.
>       The source code expects a header of zero bytes in the
>       pcap output of zero bytes (hard coded in the source).
>       My captures have a "linux cooked capture" header of sixteen bytes.
>       Changing an offset from zero to sixteen gets it to work.
>    b: Requires traffic on the interface.
>       It seems it gets into a loop and awaits some traffic.
>       It examines it - if it is data it expects it uses it.
>       If it is other data from other programmes accessing the 'net
>       it does nothing with it.
>       In both those cases it moves on and starts over.
>       What if there is no traffic? Unless there is something for it
>       either to use or ignore, it seems to hang. To get it to work
>       I have to, say, read the NY Times online while running it.
>       (I believe the traceproto site mentions doing something to
>       get around the timeout problem)
>    Output is OK - but I don't really like it.
> 3: Tcptraceroute
>    I have used this since kernel 2.2 through 2.4
>    (older version with older version of libnet) and
>    2.6.5, 2.6.7, 2.6.9, 2.6.10, 2.6.11, 2.6.12
>    It was my favourite until I got traceproto.
> 4: Traceproto
>    I have used this in kernels 2.4,
>    2.6.5, 2.6.7, 2.6.9, 2.6.10, 2.6.11, 2.6.12
>    Good.
> 
> 
> In kernel 2.6.13: [patching 2.1.12 with the patch file]
> 
>  Standard "traceroute" works.
>  LFT works.
>  HPING works (also in traceroute mode).
>  tcptraceroute fails.
>  traceproto (tcp or udp mode) fails.
> 
> How do they fail?
> 
> A TCPDUMP shows that they do send out the packets.
> I do get back ICMP "time exceeded" error messages.
> They no longer recognize them.
> 
> Something that had never changed before has now changed
> and has broken traceproto and tcptraceroute. 

[netdev CC'ed]

Could you provide tcpdump dumps and your .config file please?
