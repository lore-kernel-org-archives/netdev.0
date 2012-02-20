From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: make bnx2x_close() static again
Date: Sun, 19 Feb 2012 19:05:49 -0500 (EST)
Message-ID: <20120219.190549.1029121774253005584.davem@davemloft.net>
References: <1329395928-998-1-git-send-email-mschmidt@redhat.com>
	<D4345541C14421439B1167B74C9F383537EEF3@SJEXCHMB05.corp.ad.broadcom.com>
	<1329399341.16698.33.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab2BTAFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 19:05:53 -0500
In-Reply-To: <1329399341.16698.33.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 16 Feb 2012 15:35:40 +0200

>> Subject: [PATCH] bnx2x: make bnx2x_close() static again
>> 
>> Commit 8304859a "bnx2x: add fan failure event handling" made the function
>> bnx2x_close() non-static unnecessarily. The function is not called from
>> other sources. Make it static again.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
 ...
> Acked-by: Yuval Mintz <yuvalmin@broadcom.com>

Applied.
