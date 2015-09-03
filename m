From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Support ip route get via given table
Date: Thu, 03 Sep 2015 15:40:15 -0700 (PDT)
Message-ID: <20150903.154015.1172003362734952780.davem@davemloft.net>
References: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbbICWkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 18:40:16 -0400
In-Reply-To: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  2 Sep 2015 12:03:12 -0700

> Add support for 'ip [-6] route get table X' where the user wants to
> force the FIB lookup from a given table.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

As Thomas mentioned, this adds cost to the FIB lookup fastpath
for a control-plane only feature, which is really undesirable.

I think I'll pass on this change for now, sorry.
