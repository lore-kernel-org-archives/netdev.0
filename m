From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 14:10:06 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921011BE869@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

jamal writes: 
> On Mon, 15 Apr 2002, Milam, Chad wrote:
> 
> > At the end of the day, my patch was not trying to avoid GC, or eliminate
> > it.  It was just
> > there to keep the box from going completely dead...
> 
> I dont think yourt patch guarantees this (you are nuking routes that
> may still be actively used) -- i think you may have been lucky so far.
> Regardless, this seems to be  an interesting case of fixing what appears
> to be a application bug with a kernel patch. Its amazing what you can do
> when you have source.
> 
> cheers,
> jamal
> 
> PS:- the fact that you are running 2.2 is useful information that
> you left out.
> 

the fact that i am using 2.2 is stated in the subject line. i did neglect to 
put it explicitly put it in the message (sorry).  it is, however, also 
diff/patch file.

I also do not think that nuking valid routes in the cache will produce any
major issues, other than slowing things down for a few seconds.  the cache
is just the cache, not the real route table. and yes, it pretty much 
guarantees the route cache will be purged, therefore avoiding a reboot and
avoiding a quickly repeated overflow...

and yes, having the source makes things much easier. :)

chad
