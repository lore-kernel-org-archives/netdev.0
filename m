From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG] ixgbe: something wrong with queue selection ?
Date: Tue, 17 Apr 2012 18:07:11 +0100
Message-ID: <1334682431.2565.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <4F8D9C91.5010001@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	<jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9385 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754968Ab2DQRHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 13:07:16 -0400
In-Reply-To: <4F8D9C91.5010001@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 09:38 -0700, John Fastabend wrote:
[...]
> We could consider using sk_tx_queue_get(sk) in select_queue or better
> yet use XPS and initialize it at sw init time. I think this would work
> nicely and finally remove the select_queue() logic I just haven't got
> to it yet. Hoping to get there the next few weeks.

Anything like <http://thread.gmane.org/gmane.linux.network/186700/>?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
