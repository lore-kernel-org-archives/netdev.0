From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [TIPC] Fixed skb_under_panic caused by
 tipc_link_bundle_buf
Date: Thu, 29 Jun 2006 12:41:42 -0700 (PDT)
Message-ID: <20060629.124142.102573938.davem@davemloft.net>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
	<11514964722073-git-send-email-per.liden@ericsson.com>
	<Pine.LNX.4.64.0606291703270.1695@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33721
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751252AbWF2Tln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:41:43 -0400
To: per.liden@ericsson.com
In-Reply-To: <Pine.LNX.4.64.0606291703270.1695@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Thu, 29 Jun 2006 17:17:20 +0200 (CEST)

> A problem was found with this patch. The direct inspection of bundle 
> buffer tailroom did not account for the possiblity of unrequested tailroom 
> added by skb_alloc(), thereby allowing a bundle to be created that exceeds 
> the current link MTU.
> 
> I'll resend this patch set with this issue resolved.

I've applied the patch already, please send a relative fix.
Thanks.
