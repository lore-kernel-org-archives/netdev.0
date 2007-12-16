From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 15:37:46 -0800
Message-ID: <20071216153746.aa4f5e72.rdunlap@xenotime.net>
References: <20071211154835.75ace6bc@freepuppy.rosehill>
	<20071216.133717.202852113.davem@davemloft.net>
	<20071216142915.c120d25c.akpm@linux-foundation.org>
	<20071216.152606.35263254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, jeff@garzik.org, herbert@gondor.apana.org.au,
	rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:44395 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760641AbXLPXhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 18:37:51 -0500
Received: from midway.site ([71.117.233.180]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 15:37:47 -0800
In-Reply-To: <20071216.152606.35263254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 15:26:06 -0800 (PST) David Miller wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sun, 16 Dec 2007 14:29:15 -0800
> 
> > On Sun, 16 Dec 2007 13:37:17 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > > Date: Tue, 11 Dec 2007 15:48:35 -0800
> > > 
> > > > Subject: Re: [PATCH] bridge: assign random address
> > > 
> > > "bridge" should all-caps and in brackets,
> > 
> > No, "bridge" should not be in [].  Lots of people's patch-receiving scripts
> > assume that any text in [] is to be removed as the patch is committed.  It
> > contains text which is only relevant to the particular email which carried
> > the patch.  Stuff like "patch" and "4/5" and "linux-2.6.23", etc.
> 
> I don't use scripts, I edit it by hand.  And when I do ever use
> scripts I will make sure they accomodate "[$SUBSYSTEM]" format
> subject lines, you can be sure.
> 
> And you can even make those scripts happy by doing:
> 
> [Patch 1/7] [SUBSYSTEM]: Foo bar baz...
> 
> And if you haven't noticed over the past few years, this is
> is the convention we've been using in the networking.
> 
> I munge every one of your (and everyone else's) changelog entry
> headers this way.  Without exception, every single one.
> 
> So when you don't follow this convention, you make more typing
> and more work for me.  The more patches I get from someone
> the more important it is for this convention to be followed.
> 
> I find it very hard to believe that you haven't once looked
> at the hundreds of patches I've applied of your's and not
> noticed how I reformat everything.

I have noticed the difference in networking vs. rest-of-kernel.
Rest-of-kernel generally follows the canonical format in
Documentation/SubmittingPatches:

14) The canonical patch format

The canonical patch subject line is:

    Subject: [PATCH 001/123] subsystem: summary phrase


---
~Randy
