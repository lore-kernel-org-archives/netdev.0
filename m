From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH][NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 15:55:39 -0300
Message-ID: <39e6f6c7050326105553789ae6@mail.gmail.com>
References: <20050326144516.GA21949@conectiva.com.br>
	 <1111854140.9195.199.camel@pegasus>
	 <1111854713.9195.202.camel@pegasus>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1111854713.9195.202.camel@pegasus>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 17:31:53 +0100, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Arnaldo,
> 
> > >     Here is an updated patch, taking, I hope, all of Marcel
> > > considerations into account and also fixing a bug in proto_register,
> > > I was returning on error without dropping the lock.
> >
> > the error path of some init function in the Bluetooth subsystem is still
> > wrong. 

Which one? I'll check...

>> And I don't really like your way of using the labels, because
> > this twists my brain too much. 

Oh well, this is how things are done all over the place, but lets be fair
with your brain ;)

>> I fixed all of these and while we are at
> > it, I cleaned up the init functions. Please use the attached patch
> > instead of your changes to the Bluetooth subsystem.

Whatever, I'll cook up a new patch with your changes for bluetooth.

> oops, I forgot to include hci_sock.c into that patch. Here is a fixed
> one.

Regards,

- Arnaldo
