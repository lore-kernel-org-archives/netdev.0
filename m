From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 12:07:37 -0300
Message-ID: <20050118120737.I15303@almesberger.net>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106058592.1035.95.camel@jzny.localdomain>; from hadi@cyberus.ca on Tue, Jan 18, 2005 at 09:29:52AM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2005-01-18 at 08:44, Thomas Graf wrote:
> > I'm aware of [tcng] but naturally it always lags behind a bit and keeping
> > it up to date requires quite some work and I already have problems
> > finding the time for my own changes ;-> 

Sigh, yes, I don't have all that much time for it myself, and
my focus of interest has shifted, too. Unfortunately, everybody
I've tried to talk in to taking over its maintenance so far was
wise enough to politely pass up the offer :-(

There's also the issue of classifier construction: while I think
that the language for this is near-perfect, the internal
processing is scary at best, and doesn't produce very nice
results. I dream of a new classifier works on a state machine
constructed from single-bit classification decisions, but the
graph theory required for ordering them properly is a bit above
me. (Construction of an unordered and redundant FSM is almost
trivial - tcng can already do this.)

> >  - interactive shell supporting context help + completion
> 
> MUST

I'm not so sure about interactive use of "tc". In general, a
single configuration line has no meaning. You almost always
need a lot more context to understand what it does.

Think of the interactive BASIC systems on ancient PCs. There,
you would enter/edit/remove lines by their number. Now, would
you want to use something like this for C ? Me, I prefer a
free-format text editor :-)

An interactive help system that could be called from an
editor, e.g. when editing tcng configurations, would certainly
be a nice touch. But that's an orthogonal issue. A set of man,
info, etc. pages would serve nicely, too.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
