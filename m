From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [patch 1/8] Update smc91x driver with ARM Versatile board info
Date: Fri, 20 Oct 2006 22:50:40 +0100
Message-ID: <20061020215039.GI8894@flint.arm.linux.org.uk>
References: <200610202142.k9KLg4om003709@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dsaxena@plexity.net,
	nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:24338 "EHLO
	caramon.arm.linux.org.uk") by vger.kernel.org with ESMTP
	id S2992599AbWJTVuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 17:50:50 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200610202142.k9KLg4om003709@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 02:42:04PM -0700, akpm@osdl.org wrote:
> We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
> generic IRQ layer will complain thusly:

I don't think I heard anything back from my previous suggestion that
the IRQ flags are passed through the platform device IRQ resource.

Doing so would avoid adding yet another platform specific block into
the file.

BTW, Integrator platforms will also suffer from this, which will add
another ifdef to this header.

Let's do it right and arrange to pass these flags from the platform
code.  It's not like they're in a critical path.

-- 
Russell King
