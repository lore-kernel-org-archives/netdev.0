From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 14:09:01 +0100
Message-ID: <1111842541.9195.183.camel@pegasus>
References: <20050326003937.GA13951@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <20050326003937.GA13951@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

> 	Please take a look and apply if acceptable, full description is
> on the changeset.
> 
> 	Ah, I started using __ as a separator between class name and
> method, I've been using this in some client projects and find it useful
> for grepping and for ctags, as it eliminates some false positives and
> do namespacing more strongly, please tell me if you don't like it.
> 
> 	If this is accepted the next changesets probably will move
> struct proto and the proto__ routines to net/core/prot.{c,h} and I'll
> add proto__ prefix to all struct proto members, etc.

I personally don't like the __ separator thing. Is this really needed?
What is wrong with using "proto_register()"? Where is the advantage?

And please don't convert from using "err" to "rc" for the return value
of the init function. In the case of the Bluetooth subsystem we never
call these variables "rc" and thus you are messing things up.

Regards

Marcel
