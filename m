From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] macvtap: Correctly set tap features when
 IFF_VNET_HDR is disabled.
Date: Tue, 20 Aug 2013 13:09:41 -0700 (PDT)
Message-ID: <20130820.130941.657651846878316362.davem@davemloft.net>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
	<1376681102-19753-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab3HTUJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:09:42 -0400
In-Reply-To: <1376681102-19753-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 Aug 2013 15:25:01 -0400

> When the user turns off IFF_VNET_HDR flag, attempts to change
> offload features via TUNSETOFFLOAD do not work.  This could cause
> GSO packets to be delivered to the user when the user is
> not prepared to handle them.
> 
> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
> disabled.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
