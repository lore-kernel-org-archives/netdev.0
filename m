From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: eth1 became eth2, but dmesg still says eth1
Date: Sun, 6 May 2007 14:46:30 -0400
Message-ID: <20070506184630.GD6222@tau.solarneutrino.net>
References: <20070506053824.GC6222@tau.solarneutrino.net> <bde4e1140705060919l46f40a1ajf0d38426b02c5d7d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Emil S Tantilov <emils.tantilov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from solarneutrino.net ([66.199.224.43]:2097 "EHLO
	tau.solarneutrino.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbXEFSqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 14:46:32 -0400
Content-Disposition: inline
In-Reply-To: <bde4e1140705060919l46f40a1ajf0d38426b02c5d7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 06, 2007 at 09:19:40AM -0700, Emil S Tantilov wrote:
> >However the bond0 interface failed to come up, complaining that there
> >was no such interface as eth1.  I checked /proc/net/dev, and it listed
> >eth0 and _eth2_.  I changed the bonding configuration to use eth0 and
> >eth2 and it's working fine now.
> 
> Check your udev rules. This is usually what is causing interface to
> come up differently than what you would expect.

Thanks, I was unaware that udev had a hand in that.  It appears to be a
bug in Debian's udev configuration generator.

-ryan
