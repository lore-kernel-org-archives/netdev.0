From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Allow setting dev->weight using ip(8)
Date: 30 Aug 2004 08:27:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093868860.1075.573.camel@jzny.localdomain>
References: <5cac192f040830035669628d1@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f040830035669628d1@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 06:56, Eric Lemoine wrote:
> Hello
> 
> For my own testing purposes, I often need to modify dev->weight. So I
> patched the kernel and iproute2 to be able to modify dev->weight using
> ip(8). After all, one can modify tx_queue_len so why not weight?
> 
> Two kernel patches attached: one using the ioctl framework and another
> using the rtnetlink framework. Warning: the attached rtnetlink patch
> is a superset of Thomas Graf's rtnetlink patch for setting mtu and
> tx_queue_len.
> 
> PS: both patches are against 2.6.5-rc3-ben0 but should apply to any 2.6.
> 

Looks sane.
Not sure if you should encourage ioctl though ;-> 
Out of curiosity, what/when do you change weight? I think its valuable
to do so, just curious. BTW, As Dave pointed out alwauIFLA_WEIGHT

missing user space/ip patch btw.

cheers,
jamal
