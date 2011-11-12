From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] r8169: add module param for control of ASPM  disable
Date: Sat, 12 Nov 2011 04:59:36 +0000
Message-ID: <20111112045935.GA24292@srcf.ucam.org>
References: <1321052755-15368-1-git-send-email-tbroch@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:55652 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab1KLE7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 23:59:44 -0500
Content-Disposition: inline
In-Reply-To: <1321052755-15368-1-git-send-email-tbroch@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2011 at 03:05:55PM -0800, Todd Broch wrote:
> ASPM has been disabled in this driver by default as its been
> implicated in stability issues on at least one platform.  This CL adds
> a  module parameter to allow control of ASPM disable.  The default
> value is to enable ASPM again as its provides signficant (200mW) power
> savings on the platform I tested.

The default is then to break some hardware. That's not reasonable. 
Instead, we need to identify which chip versions are broken and limit 
the blacklist to them.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
