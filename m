From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Do not wrap sysctl igmp_max_memberships in
 IP_MULTICAST
Date: Tue, 12 Apr 2011 14:00:16 -0700 (PDT)
Message-ID: <20110412.140016.189701267.davem@davemloft.net>
References: <1302601774-24289-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932484Ab1DLVAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:00:52 -0400
In-Reply-To: <1302601774-24289-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Tue, 12 Apr 2011 11:49:34 +0200

> controlling igmp_max_membership is useful even when IP_MULTICAST
> is off.
> Quagga(an OSPF deamon) uses multicast addresses for all interfaces
> using a single socket and hits igmp_max_membership limit when
> there are 20 interfaces or more.
> Always export sysctl igmp_max_memberships in proc, just like
> igmp_max_msf
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

I really like your commit message, a full justification and a
reference to existing similar behavior.

If only every patch submitter did this :-/

Applied, thanks!
