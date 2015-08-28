From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:48:03 -0700 (PDT)
Message-ID: <20150827.224803.1307093033865872360.davem@davemloft.net>
References: <55DFEDA1.2070903@cumulusnetworks.com>
	<20150827.221753.1685094662698420131.davem@davemloft.net>
	<55DFF28B.4050302@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbH1FsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:48:03 -0400
In-Reply-To: <55DFF28B.4050302@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 22:32:59 -0700

> TP_printk is not printk. See my other response.

Then I consider TP_printk to be broken.

Forcing you to memcpy() ipv4 addresses in the "fast assign" of a trace
point is completely stupid.
