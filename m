From: "J. Simonetti" <jeroens@office.netland.nl>
Subject: Re: 2.6.10 dst cache overflow
Date: Thu, 17 Feb 2005 15:42:26 +0100
Message-ID: <1108651346.497.10.camel@ts2.office.netland.nl>
References: <1108550412.3799.81.camel@ts2.office.netland.nl>
	 <42134E22.4030808@davidcoulson.net>
	 <16915.22671.276946.919243@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Coulson <david@davidcoulson.net>, netdev@oss.sgi.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16915.22671.276946.919243@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-16 at 15:28, Robert Olsson wrote:
> Hello!
> 
> Very recently here on netdev "Memory leak in 2.6.11-rc1" was discussed 
> this resulted in:
>  
> > ===== net/ipv4/ip_output.c 1.74 vs edited =====
> > --- 1.74/net/ipv4/ip_output.c	2005-01-25 01:40:10 +01:00
> > +++ edited/net/ipv4/ip_output.c	2005-01-30 18:54:43 +01:00
> > @@ -389,6 +389,7 @@
> >  	to->priority = from->priority;
> >  	to->protocol = from->protocol;
> >  	to->security = from->security;
> > +	dst_release(to->dst);
> >  	to->dst = dst_clone(from->dst);
> >  	to->dev = from->dev;  
> 
> and a similar patch for ipv6. Should be a start.

After reading the thread and doing some research of my own it looks like
that is what I'm suffering from. I will try the patch to see if it
helps.
Thank you for the help.

Jeroen Simonetti
--
Netland Internet Services
http://www.netland.nl

Increased knowledge will help you now.  Have mate's phone bugged.
