From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] bonding.h: "extern inline" -> "static inline"
Date: Thu, 18 Jan 2007 22:07:31 -0500
Message-ID: <45B035F3.1060303@garzik.org>
References: <20061212162439.GX28443@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, ctindel@users.sourceforge.net,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47731 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964778AbXASDHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:07:38 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061212162439.GX28443@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> "extern inline" generates a warning with -Wmissing-prototypes and I'm
> currently working on getting the kernel cleaned up for adding this to
> the CFLAGS since it will help us to avoid a nasty class of runtime
> errors.
> 
> If there are places that really need a forced inline, __always_inline
> would be the correct solution.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


