From: jamal <hadi@cyberus.ca>
Subject: Re: udp weirdness
Date: Fri, 27 Sep 2002 10:53:00 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209271048160.4401-100000@shell.cyberus.ca>
References: <20020927120223.GH343@hookipa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
In-Reply-To: <20020927120223.GH343@hookipa>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 27 Sep 2002, Eric Lemoine wrote:

> I figured out that packets can be dropped in pfifo_fast_enqueue()
> [the default qdisc's enqueue func], even though the driver/kernel
> flow control has triggered.
>
> And sendto does not notify the user when packet gets dropped because
> the output queue overflows (as indicated in sendto manpage).
>
> Why doesn't the kernel just put the process into sleep instead of
> dropping packets?
>

What trigger do you suggest to wake up the process again?
A better idea maybe to return something to the socket so it can
manage things instead -- not sure what to return though that wouldnt
break some standard;

cheers,
jamal
