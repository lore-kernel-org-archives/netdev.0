From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix spinfo_srtt to be in msecs and not
 jiffies
Date: Thu, 15 Jun 2017 12:15:57 -0400 (EDT)
Message-ID: <20170615.121557.573870132240215519.davem@davemloft.net>
References: <ed45c6f580535de366377e20af519ecff5bdf28d.1497466458.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdFOQP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:15:59 -0400
In-Reply-To: <ed45c6f580535de366377e20af519ecff5bdf28d.1497466458.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 14 Jun 2017 16:08:59 -0300

> RFC 6458 (SCTP Sockets API) Section 8.2.2.  Peer Address Information
> (SCTP_GET_PEER_ADDR_INFO) defines that spinfo_srtt is in miliseconds,
> yet we were using it in jiffies.
> 
> Fix it by converting before assigning, similarly to RTO.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> I hope this is not considered UAPI breakage. This is exported via
> getsockopt() calls.

Unfortunately it is UAPI breakage, it is too late to change this now.

SOrry.
