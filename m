From: "Milam, Chad" <Chad_Milam@nyc.yr.com>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 15:54:21 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <D4CA6B275AA33241AC771F0C0B43A921010CE7E0@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

I lowered the timeout to make gc more agressive.  Though, it can still
be adjusted via a /proc entry.  Default was 300. Increasing the other
parameters that you specified (which I have done) only delays the 
inevitable "dst cache overflow".  The problem is that gc (rather
rt_free) is not decrementing .entries.  So it _thinks_ the table
has overflown.

chad


>  -----Original Message-----
> From: 	owner-netdev@oss.sgi.com@YRINC   On Behalf Of jamal <hadi@cyberus.ca>
> Sent:	Sunday, April 14, 2002 3:44 PM
> To:	Milam, Chad
> Cc:	netdev@oss.sgi.com
> Subject:	Re: dst cache overflow 2.2.x; x>=16
> 
> 
> 
> On Sun, 14 Apr 2002, jamal wrote:
> 
> >
> > Hi,
> >
> > Why couldnt you just modify the parameters in /proc?
> >
> > -Increase the overflow threshold (you actually hardcode this)
> > /proc/sys/net/ipv4/route/gc_thresh
> > -decrease the gc timer
> > /proc/sys/net/ipv4/route/gc_timeout
> 
> Sorry, you hardcoded /proc/sys/net/ipv4/route/gc_timeout
> to 120 secs.
> 
> cheers,
> jamal
> 
