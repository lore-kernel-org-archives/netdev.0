From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] moving the test for sockaddr->sa_family up
Date: Mon, 17 Nov 2003 12:44:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117124443.7590c1d4.davem@redhat.com>
References: <20031115212034.GA16326@conectiva.com.br>
	<Xine.LNX.4.44.0311160855020.31201-100000@thoron.boston.redhat.com>
	<20031116190757.GA18416@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031116190757.GA18416@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Nov 2003 17:07:58 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Em Sun, Nov 16, 2003 at 08:56:04AM -0500, James Morris escreveu:
> > On Sat, 15 Nov 2003, Arnaldo Carvalho de Melo wrote:
> > 
> > > Does anybody see any problem with this simplification? Not for 2.6.0, of
> > > course...
> > 
> > No, looks like a good idea.  Might be able to push address length 
> > verification up there too.
> 
> Not really, look at the ax25 code... :-\ They have to support two address types,
> if we want to keep this flexibility we can't check it at the upper layer,
> does anybody here knows if we want or if we can ditch that thing in ax25? this:

Right, this is the area where you need to be careful, where people
need special semantics just like this ax25 case.

I'm %100 fine with the original cleanup for 2.6.1 or later.
