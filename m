From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 09:59:02 +0800
Message-ID: <1369879142.2903.0.camel@cr0>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
	 <20130528.233647.1209227470109213894.davem@davemloft.net>
	 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	horms@verge.net.au
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759777Ab3E3B7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 21:59:15 -0400
In-Reply-To: <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 20:34 +0100, Ben Hutchings wrote:
> On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> > 
> > So something like "X = (typeof(X)) ~0U;".
> 
> I think you mean ~(typeof(X))0.
> 

Good catch, I will change it to ~(typeof(X))0.
