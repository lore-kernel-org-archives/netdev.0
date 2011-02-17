From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the
 probe
Date: Thu, 17 Feb 2011 11:32:19 +0100
Message-ID: <1297938739.9613.4.camel@ceranb.intra.cera.cz>
References: <483985247.35721.1297792863958.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
	 <1297931060.9613.2.camel@ceranb.intra.cera.cz>
	 <20110217101901.GA11897@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15583 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab1BQKcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 05:32:41 -0500
In-Reply-To: <20110217101901.GA11897@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-17 at 11:19 +0100, Francois Romieu wrote:
> Ivan Vecera <ivecera@redhat.com> :
> [...]
> > Dave, Francois, is it acceptable?
> 
> Apparently both are acceptable. :o/
> 
> As a mildly convinced coward, I can not tell if it will help more applications
> than it will break.
> 
It should not break any application as the patch only avoids the
operstate to be 'unknown' instead of 'up'.


