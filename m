From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 16:27:18 +0100
Message-ID: <1309188438.2744.5.camel@bwh-desktop>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	 <1309187108-12715-3-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27664 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab1F0P1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:27:22 -0400
In-Reply-To: <1309187108-12715-3-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-27 at 10:05 -0500, Jon Mason wrote:
> Clean up watchdog reset code:
>  - move code that checks for stuck slice to a common routine
>  - unless there is a confirmed h/w fault, verify that a stuck
>    slice is still stuck in the watchdog worker; if the slice is no
>    longer stuck, abort the reset.
>  - this removes an egregarious 2000ms pause in the watchdog worker that
[...]

Egregious & gregarious?  Or maybe just egregious?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

