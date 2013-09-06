From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Restore a call to config_init
Date: Fri, 06 Sep 2013 14:47:33 -0400 (EDT)
Message-ID: <20130906.144733.708978789363351557.davem@davemloft.net>
References: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab3IFSrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:47:36 -0400
In-Reply-To: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Fri, 6 Sep 2013 12:55:02 +0300

> Commit c0a77ec74f295013d7ba3204dd3ed25fccf83cb4 'bnx2x: Add missing braces in
> bnx2x:bnx2x_link_initialize' identified indentation problem, but resolved it
> by adding braces instead of fixing the indentation. The braces now prevents a
> config_init call in some cases, though it should be called regardless of that
> condition. This patch removes the braces and fix the confusing indentation
> that caused this mess.
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
