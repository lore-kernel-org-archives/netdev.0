From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Thu, 29 Mar 2012 19:09:35 +0100
Message-ID: <1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120329163800.GH24933@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53693 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758417Ab2C2SJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 14:09:42 -0400
In-Reply-To: <20120329163800.GH24933@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 09:38 -0700, Marc MERLIN wrote:
[...]
> Below are some sysreq dumps I took (syslog to local disk was still
> working fine). I know I have Tainted 'G', and I have no idea where that
> came from, sorry :-/
[...]

'G' isn't a taint flag, but the following 'O' is; it means you have one
or more out-of-tree modules loaded.  Care to tell us what they are?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
