From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: move and rename netif_notify_peers()
Date: Fri, 10 Aug 2012 20:01:16 +0100
Message-ID: <1344625276.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6911 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755162Ab2HJTBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 15:01:20 -0400
In-Reply-To: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 16:14 +0800, Cong Wang wrote:
> I believe net/core/dev.c is a better place for netif_notify_peers(),
> because other net event notify functions also stay in this file.
> 
> And rename it to netdev_notify_peers().
[...]

Is there a convention for using the 'netdev' vs 'netif' prefixes?
If not, I don't see the point in renaming just this one function.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
