From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: SMSC 9303 support
Date: Tue, 24 Sep 2013 17:51:28 +0100
Message-ID: <1380041488.2736.41.camel@bwh-desktop.uk.level5networks.com>
References: <524183D6.6040801@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17009 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab3IXQvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:51:32 -0400
In-Reply-To: <524183D6.6040801@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 06:21 -0600, Gary Thomas wrote:
> I need to support the SMSC9303 in an embedded system.  I'm not
> finding any [explicit] support for this device in the latest
> mainline kernel.  Did I miss something?
> 
> To be clear, the SMSC9303 is a 3-port managed ethernet switch
> capable of supporting 802.1D/802.1Q directly. This switch is
> driven by a single MAC via MII/RMII and exposes the other two
> ports via physical PHYs.  What I need it to do is behave like
> two external, separate devices.  I was thinking that what I need
> to do is treat these as VLAN devices since the switch can manage
> the routing.
> 
> Does this seem like a reasonable approach?

Linux has 'DSA' (Distributed Switch Architecture) which supports tagging
of packets to indicate which switch port they are sent or received
through.  This was originally added to support some Marvell switch chips
and I don't know whether it would be suitable or extensible for this
one.

Ben.

> How do I "hook up" my normal ethernet driver to it?  To the hardware
> it just looks like any other MII/RMII PHY.  The device is managed
> separately via I2C.  I can have that set up separately if necessary.
> 
> Thanks for any pointers/ideas
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
