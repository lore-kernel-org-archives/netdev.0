From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [bonding][2/3] Synchronizing 2.4-2.6
Date: Sun, 31 Aug 2003 15:19:39 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C94EB@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Hen, Shmulik" <shmulik.hen@intel.com>, "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Hen, Shmulik 
> Sent: Saturday, August 30, 2003 10:40 PM
> To: Jeff Garzik
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: Re: [bonding][2/3] Synchronizing 2.4-2.6
> 
> On Thursday 28 August 2003 07:02 pm, Jeff Garzik wrote:
> > Hen, Shmulik wrote:
> > > After patch set 1, It should be as easy as just copying all the
> > > bonding related files from 2.4 to 2.6. I guess I can do that on
> > > Sunday if someone hasn't already done it before.
> >
> > I had hoped to preserve the revision history.  Simply copying the
> > files over does not do that :(
> >
> > What I mean by preserving revision history is, changes should be
> > submitted to 2.6 in the same granularity as they were to 2.4...
> >
> 
> Amir, on the other hand, understood exactly what you intended, so 
> there should be something ready for tomorrow that brings 2.6 to the 
> same point as 2.4 after set 1, in small steps. After that, sets 2 and 
> 3 could be applied the same way for 2.4 and 2.6.
> 

May have spoken a bit too soon. It seems it won't be possible
to get sets 2 and 3 to apply the same way for 2.4 and 2.6.
In 2.6, things like MOD_{INC|DEC}_USE_COUNT are already gone,
and struct initializers have already been converted to c99
style. Probably some other things as well. Since we don't want
the code to have ugly ifdefs in it, we'll need to either split
the code :(, or backport more stuff from 2.6 to 2.4 :).

We'll have to get back to that later this week (probably
not before Wednesday, since there is a pressing internal
deadline for us due by Tuesday).


	Shmulik.
