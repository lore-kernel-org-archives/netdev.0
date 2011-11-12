From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: add module param for control of ASPM  disable
Date: Sat, 12 Nov 2011 11:46:24 +0100
Message-ID: <20111112104624.GA24870@electric-eye.fr.zoreil.com>
References: <1321052755-15368-1-git-send-email-tbroch@chromium.org> <20111112045935.GA24292@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60906 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1KLKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 05:51:25 -0500
Content-Disposition: inline
In-Reply-To: <20111112045935.GA24292@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Garrett <mjg59@srcf.ucam.org> :
> On Fri, Nov 11, 2011 at 03:05:55PM -0800, Todd Broch wrote:
> > ASPM has been disabled in this driver by default as its been
> > implicated in stability issues on at least one platform.  This CL adds
> > a  module parameter to allow control of ASPM disable.  The default
> > value is to enable ASPM again as its provides signficant (200mW) power
> > savings on the platform I tested.
> 
> The default is then to break some hardware. That's not reasonable. 
> Instead, we need to identify which chip versions are broken and limit 
> the blacklist to them.

Yes, assuming it's only a device problem.

Todd, which chipset(s) (XID or such) was it tested with ?

It would be nice to know the kind of use as well (desktop / laptop / server).

Btw, what is a 'CL' ?

-- 
Ueimor
