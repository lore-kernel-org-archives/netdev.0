From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 09:11:41 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210140901570.26803-100000@shell.cyberus.ca>
References: <3DAABBAE.79E22EB6@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DAABBAE.79E22EB6@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 14 Oct 2002, Stefan Rompf wrote:

> Alexey, Jamal,
>
> the first version of this patch just added the feature to distribute
> state changes created by netif_carrier_on()/_off() inside the kernel and
> to netlink via netdev_state_change(). This is still the part most
> important to me - not only in 2.5, but also as a 2.4 backport.
>
> I don't think RFC2863 state keeping makes much sense if we cannot
> forward the results to userspace. So if you are happy with keeping the
> current semantics, but using the more sophisticated implementation of
> forwarding worked out last weekend, I'll be happy to provide a new patch
> (also adressing Jamal's nitpicks). Just agree on one way.

the RFC2863 semantics should stay; the thing we havent agreed on is
how to do it. Maybe for the first phase patch you dont need to expose them
to user space - maybe in the way Alexey suggested as attributes without
loosing any of the flag bits...
Alexey should make that call.

cheers,
jamal
