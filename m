From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Intel 82567LM e1000e DHCP problem/question
Date: Mon, 16 Mar 2009 22:23:09 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.1.10.0903162202080.5440@jbrandeb-MOBL1.amr.corp.intel.com>
References: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl> <alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com> <BAY143-W2353DFECB11A239842C4C3B99B0@phx.gbl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Pelle Svensson <pelle2004@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16664 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbZCQFXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 01:23:12 -0400
In-Reply-To: <BAY143-W2353DFECB11A239842C4C3B99B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 16 Mar 2009, Pelle Svensson wrote:
> Your assumption about the Intel AMT seems right!
> 
> Log Tracking DHCP Request when plugged net cable in:
> 
> - Power on and load Fedora -> No DHCP Request from BIOS until Desktop up
> - ifdown eth0 -> DHCP Request
> - Restart Fedora -> DHCP Request during the hole Shutdown process
> - Enter BIOS menu -> DHCP Request
> - Boot up Fedora -> DHCP Request from BIOS until Desktop up
> 
> ifdown eth0 trigged the plugged net cable DHCP Request
> 
> I tried to hit Ctrl-P frequently during the boot process but it newer display any
> management setup. I'm running Fedora 10 on Lenovo T500 bios 1.20 (6FET50WW).

Okay, maybe there is a bios setting you can change.

I am not experienced in configuring this on a t500, so I can't give you 
direct instructions.

I did find the instructions on the Intel website that someone else on the 
web said they were able to use to configure iAMT.  I think you're only 
looking to disable it.

http://download.intel.com/support/motherboards/desktop/sb/amt_quick_start_guide1.pdf

> Only AMT stuff I can find for Lenovo is related to Vista or XP, But that seems to
> for the OS not the BIOS. Can I load the Windows stuff and turn the AMT DHCP
> stuff off? I do have dual boot for XP on this PC.

I don't think that is what you want, or at least it might be more work 
than you want.

let us know how it goes.
