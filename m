From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATHCH 0/16]  ServerEngines 10Gb NIC driver
Date: Sun, 17 Feb 2008 14:35:49 +0100
Message-ID: <20080217133549.GB11132@uranus.ravnborg.org>
References: <20080217035113.d5342ffc@mailhost.serverengines.com> <20080217132536.GA11132@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:52120 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbYBQNfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 08:35:40 -0500
Content-Disposition: inline
In-Reply-To: <20080217132536.GA11132@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2008 at 02:25:36PM +0100, Sam Ravnborg wrote:
> On Sat, Feb 16, 2008 at 07:51:13PM -0800, Subbu Seetharaman wrote:
> > Patch 0/16 and 15/16 of this series are getting dropped by the
> > spam filter.  I am trying to get them across with changes
> > that will please the spam filter.  Sorry about the inconvenience.
> > Below is the 0/16 of the series.
> > 
> > --------------------------
> > Hi,
> > 
> > 
> > I am sending a patch for network driver for ServerEngines 10Gb Network adapter for review.  This patch includes the network driver and the OS neutral code that implements the interactions between the host drivers and the adapter. The adapter is a dual function device with network and storage functions.  The network driver is a regular NIC driver.  
> > 
> > The low level library that manages the interaction with the adapter is common to both storage and network drivers and hence is organized under the directory drivers/message/beclib. The storage driver is not part of this patch and will be submitted after this review.
> > 
> > This patch is made against 2.6.24.2 version of the kernel source.
> 
> Hi Subbu.
> 
> A few points about your submission (not your code as I have not looked at it).
> - Use descriptive subjects - and not the same subject for all patches
> - Include in each patch a diffstat - below the '^---' marker so
>   it is easy to spot what files are touched but so that the diffstat
>   does not get included in the changelog when applied.
> - Do not break the build. Adding Makefile/Kconfig bits as the last patch
>   usually does the trick here.
> - If you have generic funtionality add that first and then add what depnds on it
>   later.
> 
> 	Sam

I just tried scripts/checkpatch.pl - it said:

total: 250 errors, 837 warnings, 31889 lines checked

That was for the full patch-set.

I suggest you look into these. The goal is not to get down on 0/0
but close with some common sense applied.

	Sam
