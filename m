From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 1/7] bnx2x: Avoid sending multiple statistics
 queries
Date: Thu, 13 Sep 2012 16:38:39 -0400 (EDT)
Message-ID: <20120913.163839.1430346384226710502.davem@davemloft.net>
References: <1347374054-16730-2-git-send-email-yuvalmin@broadcom.com>
	<20120913.161711.2180618409918407558.davem@davemloft.net>
	<979A8436335E3744ADCD3A9F2A2B68A504B81E31@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab2IMUil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:38:41 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A504B81E31@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 13 Sep 2012 20:34:57 +0000

> But there is a difference between:
> If (A && B) {
> 	C;
> 	D;
> }
> 
> And:
> if (A) {
> 	if (B) {
> 		C;
> 	}
> 	D;
> }

Indeed, I missed the return, it make a lot more sense now.

I've applied this series to 'net' and will push it out after
build testing.

Thanks.
