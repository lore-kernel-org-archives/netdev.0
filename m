From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: sctp_remaddr_seq_show use the wrong variable
 to dump transport info
Date: Tue, 01 Mar 2016 17:36:13 -0500 (EST)
Message-ID: <20160301.173613.295919796621489412.davem@davemloft.net>
References: <08f9ec3d48c3fffd7224e6eb0c129ed113d23fbd.1456626791.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbcCAWgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:36:15 -0500
In-Reply-To: <08f9ec3d48c3fffd7224e6eb0c129ed113d23fbd.1456626791.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 28 Feb 2016 10:33:11 +0800

> Now in sctp_remaddr_seq_show(), we use variable *tsp to get the param *v.
> but *tsp is also used to traversal transport_addr_list, which will cover
> the previous value, and make sctp_transport_put work on the wrong transport.
> 
> So fix it by adding a new variable to get the param *v.
> 
> Fixes: fba4c330c5b9 ("sctp: hold transport before we access t->asoc in sctp proc")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
