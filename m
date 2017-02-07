From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: check af before verify address in
 sctp_addr_id2transport
Date: Tue, 07 Feb 2017 14:08:46 -0500 (EST)
Message-ID: <20170207.140846.1728839010237371851.davem@davemloft.net>
References: <d4c232a9f69f9eae6537f74078dc0d2a0574e8eb.1486472168.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55288 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754861AbdBGTP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:15:56 -0500
In-Reply-To: <d4c232a9f69f9eae6537f74078dc0d2a0574e8eb.1486472168.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  7 Feb 2017 20:56:08 +0800

> Commit 6f29a1306131 ("sctp: sctp_addr_id2transport should verify the
> addr before looking up assoc") invoked sctp_verify_addr to verify the
> addr.
> 
> But it didn't check af variable beforehand, once users pass an address
> with family = 0 through sockopt, sctp_get_af_specific will return NULL
> and NULL pointer dereference will be caused by af->sockaddr_len.
> 
> This patch is to fix it by returning NULL if af variable is NULL.
> 
> Fixes: 6f29a1306131 ("sctp: sctp_addr_id2transport should verify the addr before looking up assoc")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thank you.
