From: Lennert Buytenhek <buytenh@gnu.org>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Fri, 8 Nov 2002 13:28:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021108182803.GA27346@gnu.org>
References: <20021107152758.GB23858@gnu.org> <Pine.GSO.4.30.0211080605410.14675-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Boucher <marc@mbsi.ca>, bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0211080605410.14675-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, Nov 08, 2002 at 06:22:00AM -0500, jamal wrote:

> > netfilter, yeah, sure, 'could have', but please.
> 
> apology if i sounded like one of those adolescent netfilter dangerous
> fools who show up with "mama, look what i can do with a packet now that
> ive read netfilter docs"

No, you don't sound such, sorry for reacting the way i did.


> > 'Make it a netfilter module' is generally what people say when
> > they are confronted with a feature they don't like.
> 
> My angle was to avoid being intrusive to the tcp code.
> you might get a fish sent to you in .nl in an armani suit;->

Sorry but I don't like fish nor armani suits :-)


> > There was a thread about this in private mail round April this year,
> > in which some good points were raised.
> 
> There are some good points; however, whats the app for this feature?

My specific application is a proxy application that replaces the
in-kernel IP masquerading functionality, using a wildcard REDIRECT
rule plus SO_ORIGINAL_DST.  The main reason I'm doing it in userspace
is because downstream bandwidth limiting becomes a whole lot easier
this way than doing it in-kernel -- it would need complicated state
tracking and nonobvious window field manipulations if done there.

The applications that Bert and Marc named sound sane too.  There's
just a whole lot of things this thing can be used for.


cheers,
Lennert
