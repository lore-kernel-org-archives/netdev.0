From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH review] b44: Port to ssb subsystem
Date: Thu, 8 Feb 2007 16:02:11 +0100
Message-ID: <200702081602.11679.mb@bu3sch.de>
References: <200701231720.36370.mb@bu3sch.de> <1170887802.15655.14.camel@dhcp-10-7-81-58.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Gary Zambrano" <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:36446
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423008AbXBHPCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 10:02:25 -0500
In-Reply-To: <1170887802.15655.14.camel@dhcp-10-7-81-58.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 February 2007 23:36, Gary Zambrano wrote:
> On Tue, 2007-01-23 at 17:20 +0100, Michael Buesch wrote:
> > This patch ports b44 to the new SSB subsystem and makes
> > it possible to turn off PCI related stuff.
> > 
> > This patch is against my tree, where I have implemented the
> > ssb subsystem.
> > 
> > If you're all OK with this patch, I'd like apply it to my tree.
> > I think that's best. Although it's not wireless-related, it's
> > much easier to maintain this way.
> 
> >  
> > +static int b44_ethtool_ioctl (struct net_device *dev, void __user *useraddr)
> 
> Michael, Do you really want to create ethtool_ioctl() to do what the
> ethtool_ops does?

No, that was bogus code that slipped in by accident.
I merged a fixed version of this into my tree:

http://bu3sch.de/gitweb?p=wireless-dev.git;a=commitdiff;h=461bce2df6da451ba0e4b532e67c02ea5284300f

-- 
Greetings Michael.
