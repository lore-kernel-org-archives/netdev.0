From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: RE: [PATCH net-next 00/10] bnx2x: Dual-media enhancement
Date: Tue, 7 Sep 2010 13:17:24 -0700
Message-ID: <41FDA5AFCC66094F83A3D9545495A2A410BD8FD633@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1283895645.5452.60.camel@lb-tlvb-yanivr.il.broadcom.com>
 <20100907.131304.59687385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1331 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756829Ab0IGURl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 16:17:41 -0400
In-Reply-To: <20100907.131304.59687385.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
Thank you so much ! Will do.
Yaniv

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, September 07, 2010 11:13 PM
To: Yaniv Rosner
Cc: netdev@vger.kernel.org; Eilon Greenstein
Subject: Re: [PATCH net-next 00/10] bnx2x: Dual-media enhancement

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


