From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s
	X520-DA2 NIC?
Date: Wed, 18 Jan 2012 22:21:58 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
References: <1326886258.19261.25.camel@probook>
	<20120118091351.000052fc@unknown> <m3d3ag7ki8.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8172 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753372Ab2ARWWA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 17:22:00 -0500
In-Reply-To: <m3d3ag7ki8.fsf@ursa.amorsen.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
From: Benny Amorsen [mailto:benny+usenet@amorsen.dk] 
Sent: Wednesday, January 18, 2012 1:45 PM
To: Brandeburg, Jesse
Cc: Jesper Dangaard Brouer; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
Subject: Re: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2 NIC?

Jesse Brandeburg <jesse.brandeburg@intel.com> writes:

> For X520 adapters, the documentation[1] states that which SFP+ 
> adapters are/are not supported.  Direct attach cables are also 
> supported.
>
> [1] 
> http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm

I can't believe that locked optics have now arrived on commodity hardware. I have been trying to migrate to all-Intel networking at work; that effort is certainly on hold now.


That's up to you. There's "locked" and there's "locked". I'm surprised
that Benny and Jesper haven't looked at the driver to see where the
messages come from.

We have a short list of optical modules that have been tested with our
cards. The problem with standards is that there's always some wiggle
room and you won't know if something really works until you try it. No
matter how large the company, we are still constrained as far as what we
can do in a day and testing every module we can find just wasn't one of
the things that was approved for us to try.

If you have an optical module you want to try, go ahead. You may have to
modify the code a bit (last time I checked it was only in a couple of
places) and if the module actually conforms to standards you could be
OK.

Sorry about the mail formatting. That's what the give us to use.

Todd Fujinaka
Technical Marketing Engineer
LAN Access Division (LAD)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565
