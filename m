From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 10:42:20 -0300
Message-ID: <39e6f6c70503260542302b35db@mail.gmail.com>
References: <20050326003937.GA13951@conectiva.com.br>
	 <1111842541.9195.183.camel@pegasus>
	 <39e6f6c705032605136bd797b2@mail.gmail.com>
	 <39e6f6c7050326051571ef8272@mail.gmail.com>
	 <1111844163.9195.191.camel@pegasus>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1111844163.9195.191.camel@pegasus>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 14:36:03 +0100, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Arnaldo,
> 
> > Ah, apart from these style changes, do you think the real changes in this patch
> > are worth?
> 
> actually I am the wrong person to judge on this. However if socket users
> don't have to care about owner and slab anymore (or at least less), I
> think it is a good thing to do.

OK.

> Btw all the ".slab = NULL," stuff in the proto declarations is not
> needed and we normally omit values that are 0 or NULL.

I used to be a top nitpicker for this kind of stuff, and avoid it a
lot, but used
this time only to clearly state that this protocol doesn't use a slab cache,
anyway, I'll remove those as well, as we can see which protocols are not
using a slab thru /proc/net/protocols, introduced in this changeset.

> And some of the proto__seq_* functions are not static. What is the
> reason to have them public?

My mistake, thanks for pointing this out, new patch in the works.

- Arnaldo
