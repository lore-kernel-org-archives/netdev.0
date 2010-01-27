From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 1/1] starfire: clean up properly if firmware loading
 fails
Date: Wed, 27 Jan 2010 04:58:17 +0000
Message-ID: <1264568297.373.482.camel@localhost>
References: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	michael@moffatt.org.nz, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20285 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827Ab0A0E6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 23:58:23 -0500
In-Reply-To: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-26 at 20:27 -0800, akpm@linux-foundation.org wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> 
> netdev_open() will return without cleaning up net device or hardware state
> if firmware loading fails.  This results in a BUG() on a second attempt to
> bring the interface up, reported in
> <http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has even
> worse effects if the driver is removed afterwards.

David, please correct the URL above before applying the patch so I don't
continue to look like an idiot. :-)  It should be
<http://bugzilla.kernel.org/show_bug.cgi?id=15091> as added by Andrew
below.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

