From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] e1000e: get rid of wasted space
Date: Tue, 21 Oct 2008 11:23:52 +0100
Message-ID: <1224584632.3243.2.camel@achroite>
References: <20081020191149.1dbf8e3b@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:45110 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752330AbYJUKX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 06:23:57 -0400
In-Reply-To: <20081020191149.1dbf8e3b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-20 at 19:11 -0700, Stephen Hemminger wrote:
> The name in the ring is only used once during setup so it shouldn't
> be in the data structure.
[...]

No.  The name pointer passed to request_irq() has to remain valid until
the IRQ is freed.  Try looking in /proc/interrupts.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

