From: Per Liden <per.liden@ericsson.com>
Subject: RE: [PATCH 7/32] [TIPC] Multicast link failure now resets all links
 to "nacking" node.
Date: Mon, 26 Jun 2006 13:50:02 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606261343230.12417@ulinpc219.uab.ericsson.se>
References: <3A30AD378ECC6F41A4AC64F18E8B3F7F48EA08@ala-mail04.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:55991 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1750940AbWFZLuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 07:50:06 -0400
To: "Stephens, Allan" <allan.stephens@windriver.com>
In-Reply-To: <3A30AD378ECC6F41A4AC64F18E8B3F7F48EA08@ala-mail04.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2006, Stephens, Allan wrote:

[...]
> Per, I'll leave it to you to decide if you want to address James's
> concern.  But be aware that the link_reset_all() routine is only called
> to handle emergency situations when TIPC's multicast link has run into
> serious problems and is trying to recover.  Most systems will never
> follow this path, so the cost of the unnecessary
> local_bh_disable()/local_bh_enable() pairing shouldn't have any real
> impact on the overall performance of TIPC.

I tend to agree with you Allan. Since local_bh_disable()/local_bh_enable() 
supports nesting and this code is only called in extreme situations I 
don't think it's a real problem.

/Per
