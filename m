From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] offloading: Support multiple vlan tags in GSO.
Date: Mon, 01 Nov 2010 20:33:50 +0000
Message-ID: <1288643630.2231.30.camel@achroite.uk.solarflarecom.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
	 <1288390495-28923-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22487 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673Ab0KAUdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 16:33:54 -0400
In-Reply-To: <1288390495-28923-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-29 at 15:14 -0700, Jesse Gross wrote:
> We assume that hardware TSO can't support multiple levels of vlan tags
> but we allow it to be done.  Therefore, enable GSO to parse these tags
> so we can fallback to software.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
[...]

I can't see how TSO would be enabled on a second-level VLAN device;
presumably you're thinking about GSO being enabled there?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

