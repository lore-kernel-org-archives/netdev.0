From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH][BLUETOOTH] kill bt_sock_alloc
Date: Wed, 9 Mar 2005 14:43:54 -0300
Message-ID: <39e6f6c7050309094379d155e@mail.gmail.com>
References: <20050308094937.GA9468@conectiva.com.br>
	 <20050308095209.GB9468@conectiva.com.br>
	 <422F33E9.4030401@qualcomm.com>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, davem@davemloft.net, netdev@oss.sgi.com
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <422F33E9.4030401@qualcomm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Mar 2005 09:35:37 -0800, Max Krasnyansky <maxk@qualcomm.com> wrote:
> Arnaldo Carvalho de Melo wrote:
> > Em Tue, Mar 08, 2005 at 06:49:37AM -0300, Arnaldo Carvalho de Melo escreveu:
> >
> >>Hi,
> >>
> >>      Please take a look and if acceptable pull from:
> >>
> >>bk://kernel.bkbits.net/acme/connection_sock-2.6
> >
> >
> > Sorry, now with the patch attached.
> 
> Looks good to me. Marcel I'd suggest for you to apply this patch.
> It helps in reducing overall size of the socket structures.

Please note that there are further space savings to tap into in the bt_sock
class hierarchy, as not all of the bt_sock descendants  needs things like
bt_sock::accept_q,  etc

And when the "kill sk_protinfo" series is finished, there will be further space
savings, as the same bt_sock descendants that don't use accept_q will not
need to have struct connection_sock in its definition.

-- 
- Arnaldo
