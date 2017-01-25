From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: sctp_addr_id2transport should verify the
 addr before looking up assoc
Date: Wed, 25 Jan 2017 12:27:12 -0500 (EST)
Message-ID: <20170125.122712.1048162748923388120.davem@davemloft.net>
References: <2ba9d3e0b3aa05baa3791811c92248126d233c67.1485237713.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbdAYR1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:27:13 -0500
In-Reply-To: <2ba9d3e0b3aa05baa3791811c92248126d233c67.1485237713.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 24 Jan 2017 14:01:53 +0800

> sctp_addr_id2transport is a function for sockopt to look up assoc by
> address. As the address is from userspace, it can be a v4-mapped v6
> address. But in sctp protocol stack, it always handles a v4-mapped
> v6 address as a v4 address. So it's necessary to convert it to a v4
> address before looking up assoc by address.
> 
> This patch is to fix it by calling sctp_verify_addr in which it can do
> this conversion before calling sctp_endpoint_lookup_assoc, just like
> what sctp_sendmsg and __sctp_connect do for the address from users.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
