From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:05:38 -0700 (PDT)
Message-ID: <20150827.220538.2154843333132928646.davem@davemloft.net>
References: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbH1FFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:05:40 -0400
In-Reply-To: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 21:59:32 -0700

> +		__array(	__u8,	src,	4	)
> +		__array(	__u8,	dst,	4	)
 ...
> +		__array(	__u8,	src,	4	)

Maybe there is something I don't understand about tracing, but why not
use __u32?  If endianness types are the issue, just force cast it as
needed.

Using a memcpy() on a 4-byte array is kinda excessive.
