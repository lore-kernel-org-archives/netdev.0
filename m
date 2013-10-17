From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/9] bnx2x: Prevent an illegal pointer dereference
 during panic
Date: Thu, 17 Oct 2013 16:15:57 -0400 (EDT)
Message-ID: <20131017.161557.2043033136204036959.davem@davemloft.net>
References: <1381847335-32662-3-git-send-email-yuvalmin@broadcom.com>
	<20131017.142134.1058688642083607743.davem@davemloft.net>
	<1382035647.20308.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, ariele@broadcom.com,
	dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762299Ab3JQUP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:15:59 -0400
In-Reply-To: <1382035647.20308.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 17 Oct 2013 21:47:27 +0300

> I guess we should really re-spin and check for all 1's, or add some more
> code to make it really accurate, or at least fix the ">" to ">=". We
> will send a revised series with a fix.

Thanks Eilon.
