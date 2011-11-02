From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 20/21] Run tests in-process
Date: Wed, 2 Nov 2011 20:25:51 +0000
Message-ID: <1320265551.2782.9.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
	 <1320189826.2758.52.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25074 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab1KBUZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 16:25:58 -0400
In-Reply-To: <1320189826.2758.52.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-01 at 23:23 +0000, Ben Hutchings wrote:
> Change definition of main() and use of exit() so that ethtool commands
> can be tested without starting a new process.  This will allow deeper
> testing that covers ioctl requests and responses.
> 
> Fix the obvious socket and memory leaks.
[...]

Unfortunately there are more potential resource leaks than these.  I'll
defer this for now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
