From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: use read_lock_bh in sctp_eps_seq_show
Date: Sat, 10 Jun 2017 16:23:01 -0400 (EDT)
Message-ID: <20170610.162301.1998013616040326583.davem@davemloft.net>
References: <f845585a99f0cb76659f4d5dae4f7d6fd5552224.1497078812.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdFJUXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:23:02 -0400
In-Reply-To: <f845585a99f0cb76659f4d5dae4f7d6fd5552224.1497078812.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 10 Jun 2017 15:13:32 +0800

> This patch is to use read_lock_bh instead of local_bh_disable
> and read_lock in sctp_eps_seq_show.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
