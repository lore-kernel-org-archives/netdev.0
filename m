From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 10:13:31 -0300
Message-ID: <39e6f6c705032605136bd797b2@mail.gmail.com>
References: <20050326003937.GA13951@conectiva.com.br>
	 <1111842541.9195.183.camel@pegasus>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1111842541.9195.183.camel@pegasus>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 14:09:01 +0100, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Arnaldo,
> 
> >       Please take a look and apply if acceptable, full description is
> > on the changeset.
> >
> >       Ah, I started using __ as a separator between class name and
> > method, I've been using this in some client projects and find it useful
> > for grepping and for ctags, as it eliminates some false positives and
> > do namespacing more strongly, please tell me if you don't like it.
> >
> >       If this is accepted the next changesets probably will move
> > struct proto and the proto__ routines to net/core/prot.{c,h} and I'll
> > add proto__ prefix to all struct proto members, etc.
> 
> I personally don't like the __ separator thing. Is this really needed?
> What is wrong with using "proto_register()"? Where is the advantage?

Well, I stated it above, but if there are strong feelings like yours,
I'll humbly
retract that

> And please don't convert from using "err" to "rc" for the return value
> of the init function. In the case of the Bluetooth subsystem we never
> call these variables "rc" and thus you are messing things up.

Consistency, but again, strong feelings, so I'll rework the patch
removing the __
and removing the style changes I did to your subsystem.

Regards,

- Arnaldo
