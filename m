From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead
 just leave it to budget
Date: Sun, 21 Aug 2011 15:01:44 +0100
Message-ID: <1313935304.3142.22.camel@deadeye>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313911761-11709-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23443 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab1HUOBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 10:01:49 -0400
In-Reply-To: <1313911761-11709-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-21 at 00:29 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that the TX work limit is now obsolete.  Instead of
> using it we can instead rely on the NAPI budget for the number of packets
> we should clean per interrupt.  The advantage to this approach is that it
> results in a much more balanced work flow since the same number of RX and
> TX packets should be cleaned per interrupts.
[...]

This seems kind of sensible, but it's not how Dave has been recommending
people to account for TX work in NAPI.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

