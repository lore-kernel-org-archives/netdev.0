From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Fri, 29 Jan 2010 11:21:59 +0530
Message-ID: <20100129055157.GA10427@serverengines.com>
References: <20100128075633.GA4785@serverengines.com>
 <1264718429.373.520.camel@localhost>
 <20100128225114.GA1588@kroah.com>
 <1264720828.373.552.camel@localhost>
 <20100128232829.GA31884@kroah.com>
 <1264722956.373.561.camel@localhost>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>,
	stable-review@kernel.org, David Miller <davem@davemloft.net>,
	stable@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f228.google.com ([209.85.217.228]:36976 "EHLO
	mail-gx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab0A2Fvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 00:51:55 -0500
Received: by gxk28 with SMTP id 28so1424443gxk.9
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 21:51:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1264722956.373.561.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/01/10 23:55 +0000, Ben Hutchings wrote:
> On Thu, 2010-01-28 at 15:28 -0800, Greg KH wrote:
> > On Thu, Jan 28, 2010 at 11:20:28PM +0000, Ben Hutchings wrote:
> > > On Thu, 2010-01-28 at 14:51 -0800, Greg KH wrote:
> > > > On Thu, Jan 28, 2010 at 10:40:29PM +0000, Ben Hutchings wrote:
> > > [...]
> > > > > Also, you should either send this patch to stable@kernel.org, or NAK the
> > > > > addition of PCI ids for BladeEngine 3 in 2.6.32.7.
> > > > 
> > > > Why?  How does the pci id patch for 2.6.32.7 matter with this change?
> > > 
> > > Because it looks like the devices being added won't work without this.
> > 
> > Hm, what is "this"?  I seem to have been lost on this thread.
> 
> The patch I was replying to
> <http://article.gmane.org/gmane.linux.network/150441> changes I/O setup
> for be2net to use PCI BAR 0 on the new device whereas it uses BAR 1 on
> older devices.
> 
> > Care to explain it better?  2.6.32.7 is now out with the pci ids, so if
> > I need to add something else for the next .32-stable kernel, please let
> > me know.
> 
> Well that will be for Ajit to sort out.

My apologies for the confusion.
I was out of action for almost a month. As I got back few days back,
I noticed that the patch to include the new PCI IDs was pushed to
the stable kernel. So, I gathered the changes necessary for supporting the
new generation of ASIC, that were made in my absence and spun this patch.

When I mailed the patch, I was not sure when to CC stable@kernel.org
We would like to have the PCI Ids for BladeEngine 3 in 2.6.32 kernel.

Dave,
I plan rectify the error pointed by Ben and Greg and spin the patch again and
resend it.  Please let me know if you think otherwise.

Thanks
Ajit
