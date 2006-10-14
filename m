From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [patch 1/7] Update smc91x driver with ARM Versatile board info
Date: Sat, 14 Oct 2006 12:02:39 +0100
Message-ID: <20061014110239.GC15908@flint.arm.linux.org.uk>
References: <200610102133.k9ALXNI5024946@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dsaxena@plexity.net,
	nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:39692 "EHLO
	caramon.arm.linux.org.uk") by vger.kernel.org with ESMTP
	id S1752151AbWJNLCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Oct 2006 07:02:50 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200610102133.k9ALXNI5024946@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2006 at 02:33:22PM -0700, akpm@osdl.org wrote:
> From: Deepak Saxena <dsaxena@plexity.net>
> 
> We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
> generic IRQ layer will complain thusly:

Or a far better solution would be to arrange to pass the IRQ flags via
the platform device IRQ resource rather than continually having to add
to the ifdef mess in smc91x.h for every machine type we come across.

-- 
Russell King
