From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 07:19:55 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625071439.O84062@shell.cyberus.ca>
References: <20030625072602.529AF2C0B9@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, paulus@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030625072602.529AF2C0B9@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 25 Jun 2003, Rusty Russell wrote:

> Paul Mackerras says PPPoE relies on receiving packets in wire order,
> and he has bug reports caused by packet reordering.
>

I dont know of any ordering dependencies with pppoe. Is this a bug
in the ppp code?

> This is icky.

Yes it is ;->
The effects of your patch could be achieved in two ways:
a) tie the pppoe related ethernet card to a processor.
b) use a NAPI caopable ethernet card.

Now, if there is a real need to have a serialization queue (i dont see
one) you really dont need to tie to a processor. Just have a single queue
shared by all processors; every one grabs a lock to it.

cheers,
jamal
