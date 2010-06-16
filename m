From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 6/8] e1000e: enable support for EEE on
 82579
Date: Thu, 17 Jun 2010 00:52:22 +0100
Message-ID: <1276732342.14011.670.camel@localhost>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
	 <20100616232747.4834.46491.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26071 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041Ab0FPXw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:52:27 -0400
In-Reply-To: <20100616232747.4834.46491.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-16 at 16:27 -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This patch enables IEEE802.3az (a.k.a. Energy Efficient Ethernet) on the
> new 82579 LOMs.  An optional module parameter is provided to disable the
> feature if desired.
[...]

IEEE802.3az has not been finalised and I heard that some significant
changes are still required relative to the latest draft.  Given that,
any current implementation may not be interoperable with PHYs that
implement the final standard and it doesn't seem like a great idea to
enable it by default.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

