From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Thu, 6 Dec 2012 02:06:28 +0000
Message-ID: <1354759588.17107.133.camel@deadeye.wl.decadent.org.uk>
References: <50BFBE05.7020408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45912 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826Ab2LFCGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:06:33 -0500
In-Reply-To: <50BFBE05.7020408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 13:35 -0800, Ben Greear wrote:
> It seems the only way to get the current pci-e bus speed & width
> in ixgbe (and probably many other NICs) is by parsing output
> of lspci -vvv.
> 
> I'd personally find it easier if this info were available via
> ethtool API.
> 
> Any opinions on adding this info?  I was thinking something like:
[...]

This is nothing specific to network devices, so putting it in ethtool
info is totally inappropriate.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
