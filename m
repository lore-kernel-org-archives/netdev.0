From: jamal <hadi@cyberus.ca>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 13:53:29 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204151348210.15824-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE868@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE868@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org



On Mon, 15 Apr 2002, Milam, Chad wrote:

> At the end of the day, my patch was not trying to avoid GC, or eliminate
> it.  It was just
> there to keep the box from going completely dead...

I dont think yourt patch guarantees this (you are nuking routes that
may still be actively used) -- i think you may have been lucky so far.
Regardless, this seems to be  an interesting case of fixing what appears
to be a application bug with a kernel patch. Its amazing what you can do
when you have source.

cheers,
jamal

PS:- the fact that you are running 2.2 is useful information that
you left out.
