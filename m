From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] net: move and rename netif_notify_peers()
Date: Mon, 13 Aug 2012 10:46:42 +0800
Message-ID: <1344826002.22116.3.camel@cr0>
References: <1344586497-2702-1-git-send-email-amwang@redhat.com>
	 <1344625276.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab2HMCqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 22:46:55 -0400
In-Reply-To: <1344625276.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 20:01 +0100, Ben Hutchings wrote:
> On Fri, 2012-08-10 at 16:14 +0800, Cong Wang wrote:
> > I believe net/core/dev.c is a better place for netif_notify_peers(),
> > because other net event notify functions also stay in this file.
> > 
> > And rename it to netdev_notify_peers().
> [...]
> 
> Is there a convention for using the 'netdev' vs 'netif' prefixes?
> If not, I don't see the point in renaming just this one function.
> 

The reason why I rename it is there are more functions named netdev_*
than netif_* in net/core/dev.c. Also given that netdev_bonding_change()
has netdev_ prefix too.

I don't have strong opinions on this.

Thanks.
