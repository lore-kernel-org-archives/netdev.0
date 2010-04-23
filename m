From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6 1/9] sfc: Wait at most 10ms for the MC to
 finish reading out MAC statistics
Date: Fri, 23 Apr 2010 23:33:28 +0100
Message-ID: <1272062009.5520.27.camel@achroite.uk.solarflarecom.com>
References: <1272061439.5520.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46821 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab0DWWdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:33:33 -0400
In-Reply-To: <1272061439.5520.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of these 9 patches should also be applicable to 2.6.33.y, except
that one hunk of "sfc: Consistently report short MCDI responses as EIO"
is not applicable and should be dropped.

Some of the bug fixes are applicable to 2.6.32.y and maybe to 2.6.27.y,
but the patches will need some adjustment.  I intend to send backported
patches to stable@kernel.org separately.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

