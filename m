From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-pm] [Ipw2100-devel] [RFC] Runtime power management on ipw2100
Date: Mon, 19 Feb 2007 13:08:49 -0800
Message-ID: <200702191308.49797.david-b@pacbell.net>
References: <20070131075249.GA22115@srcf.ucam.org> <20070206214407.GA5254@srcf.ucam.org> <1170925306.19089.125.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, Matthew Garrett <mjg59@srcf.ucam.org>,
	ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-pm@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.sbc.mail.mud.yahoo.com ([68.142.198.201]:43893 "HELO
	smtp102.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932652AbXBSVIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 16:08:53 -0500
In-Reply-To: <1170925306.19089.125.camel@debian.sh.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 February 2007 1:01 am, Zhu Yi wrote:

> A generic requirement for dynamic power management is the hardware
> resource should not be touched when you put it in a low power state.

That is in no way a "generic" requirement.  It might apply specifically
to one ipw2100 low power state ... but "in general" devices may support
more than one low power state, with different levels of functionality.
Not all of those levels necessarily disallow touching the hardware.

> 	But I think
> freeing the irq handler before suspend should be the right way to go.

Some folk like that model a lot for shared IRQs.  It shouldn't
matter for non-sharable ones.

- Dave
