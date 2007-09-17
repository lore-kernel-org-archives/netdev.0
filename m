From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 8/8] SCTP: Tie ADD-IP and AUTH functionality as
 required by spec.
Date: Sun, 16 Sep 2007 19:35:12 -0700 (PDT)
Message-ID: <20070916.193512.14943365.davem@davemloft.net>
References: <11897955003232-git-send-email-vladislav.yasevich@hp.com>
	<1189797290519-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbXIQCfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:35:13 -0400
In-Reply-To: <1189797290519-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 15:14:50 -0400

> [.. forgot to refresh the patch, the other version has compile problems ..]
> 
> ADD-IP spec requires AUTH. It is, in fact, dangerous without AUTH.
> So, disable ADD-IP functionality if the peer claims to support
> ADD-IP, but not AUTH.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Aha, I caught this and applied the correct patch.
