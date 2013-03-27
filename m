From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Wed, 27 Mar 2013 17:34:11 -0400 (EDT)
Message-ID: <20130327.173411.1818933306949379388.davem@davemloft.net>
References: <1364408379-4353-1-git-send-email-yuvalmin@broadcom.com>
	<20130327.152716.1731476572805884795.davem@davemloft.net>
	<979A8436335E3744ADCD3A9F2A2B68A52ABF944F@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab3C0VeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 17:34:15 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52ABF944F@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 27 Mar 2013 21:08:17 +0000

> The real issue (well, both are real but this is the one THIS patch
> tries solving, while the one you describe is the one I've named
> `orthogonal') is that there exists a scenario in which the HW
> generates an interrupt although it's configured not to do so, and
> the bnx2x driver shouldn't ACK but rather discard it.

Then I'd rather you test for this situation in a cheap and explicit
manner instead of "pointer is NULL, datastructures not setup yet,
must be spurious."

Actually, in drivers, the handling of spurious interrupts is probably
the domain in which I see the most poorly thought out and implemented
patches.
