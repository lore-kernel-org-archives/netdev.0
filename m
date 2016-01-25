From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: allow setting SCTP_SACK_IMMEDIATELY by the
 application
Date: Sun, 24 Jan 2016 22:44:03 -0800 (PST)
Message-ID: <20160124.224403.165607430306052575.davem@davemloft.net>
References: <e066aaa1725a6cafb73ad270376ed2ebc953917a.1453494301.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcAYGoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 01:44:04 -0500
In-Reply-To: <e066aaa1725a6cafb73ad270376ed2ebc953917a.1453494301.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 22 Jan 2016 18:29:49 -0200

> This patch extends commit b93d6471748d ("sctp: implement the sender side
> for SACK-IMMEDIATELY extension") as it didn't white list
> SCTP_SACK_IMMEDIATELY on sctp_msghdr_parse(), causing it to be
> understood as an invalid flag and returning -EINVAL to the application.
> 
> Note that the actual handling of the flag is already there in
> sctp_datamsg_from_user().
> 
> https://tools.ietf.org/html/rfc7053#section-7
> 
> Fixes: b93d6471748d ("sctp: implement the sender side for SACK-IMMEDIATELY extension")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable, thanks.
