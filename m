From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Tue, 26 Feb 2013 17:37:58 -0500 (EST)
Message-ID: <20130226.173758.1729388485427908984.davem@davemloft.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, sri@us.ibm.com,
	nhorman@tuxdriver.com
To: lee.roberts@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3BZWiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:38:00 -0500
In-Reply-To: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>
Date: Tue, 26 Feb 2013 07:36:12 -0700

> This series of patches resolves several SCTP association hangs observed during
> SCTP stress testing.  Observable symptoms include communications hangs with
> data being held in the association reassembly and/or lobby (ordering) queues.
> Close examination of reassembly/ordering queues may show either duplicated
> or missing packets.
> 
> Lee A. Roberts (4):
>   sctp: fix association hangs due to off-by-one errors in
>     sctp_tsnmap_grow()
>   sctp: fix association hangs due to reneging packets below the
>     cumulative TSN ACK point
>   sctp: fix association hangs due to errors when reneging events from
>     the ordering queue
>   sctp: fix association hangs due to partial delivery errors

Vlad, Sridhar, and Neil, please review.
