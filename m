From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] bnx2x: Dual-media enhancement
Date: Tue, 07 Sep 2010 13:13:04 -0700 (PDT)
Message-ID: <20100907.131304.59687385.davem@davemloft.net>
References: <1283895645.5452.60.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yaniv.rosner@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757890Ab0IGUMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 16:12:47 -0400
In-Reply-To: <1283895645.5452.60.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Date: Wed, 8 Sep 2010 00:40:45 +0300

> Hi Dave,
> The following patch series describe gradually code changes to support
> dual-media boards. Among other, this change required to split common PHY
> functions into PHY specific functions, so we took advantage of this
> opportunity and moved to a method which is very similar to the phy lib,
> i.e. PHY oriented. We hope that this way will enable us to integrate
> with the phy lib easily later on.
> 
> Please consider applying it to net-next.

Applied, but you're definitely not validating your patches using
git's automatic whitespace validation checks.

Applying: bnx2x: Unify PHY attributes
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:4993: new blank line at EOF.
+
warning: 1 line adds whitespace errors.

And also:

Applying: bnx2x: Move common function into aggregated function
/home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:91: new blank line at EOF.
+
warning: 1 line adds whitespace errors.

I've fixed them up this time, but you will need to take care of these
things yourself next time or else I'll push the patches back to you.
