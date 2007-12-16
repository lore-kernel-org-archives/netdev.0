From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] SCTP: Use crc32c library for checksum
 calculations.
Date: Sun, 16 Dec 2007 14:06:54 -0800 (PST)
Message-ID: <20071216.140654.03102027.davem@davemloft.net>
References: <1197789045-3077-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759482AbXLPWHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:07:01 -0500
In-Reply-To: <1197789045-3077-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Sun, 16 Dec 2007 02:10:45 -0500

> The crc32c library used an identical table and algorithm
> as SCTP.  Switch to using the library instead of carrying
> our own table.  Using crypto layer proved to have too
> much overhead compared to using the library directly.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.25, thanks Vlad.
