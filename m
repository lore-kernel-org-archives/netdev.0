From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: refactor sctp_datamsg_from_user
Date: Thu, 29 Dec 2016 14:44:14 -0500 (EST)
Message-ID: <20161229.144414.88701034057801749.davem@davemloft.net>
References: <ba007bd30f61decbdae5c23541cbdb397c030b68.1483033905.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbcL2ToQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 14:44:16 -0500
In-Reply-To: <ba007bd30f61decbdae5c23541cbdb397c030b68.1483033905.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 29 Dec 2016 15:53:28 -0200

> This patch refactors sctp_datamsg_from_user() in an attempt to make it
> better to read and avoid code duplication for handling the last
> fragment.
> 
> It also avoids doing division and remaining operations. Even though, it
> should still operate similarly as before this patch.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
