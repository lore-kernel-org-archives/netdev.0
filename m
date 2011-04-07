From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/5] be2net: use common method to check for
 sriov function type
Date: Thu, 07 Apr 2011 09:14:01 +0100
Message-ID: <1302164041.5282.3.camel@localhost>
References: <20110407040801.GA4199@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:1536 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1DGIOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 04:14:07 -0400
In-Reply-To: <20110407040801.GA4199@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 23:08 -0500, Ajit Khaparde wrote:
> Lancer and BE can both use SLI_INTF_REG to check a VF or a PF.
[...]

This seems pretty unreliable (both in the previous and the current
version).  You cannot rely on the whole of PCI config space being mapped
to a VM guest.  KVM certainly didn't do this when I used PCI pass-
through.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

