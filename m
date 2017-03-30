From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: alloc stream info when initializing asoc
Date: Thu, 30 Mar 2017 11:08:56 -0700 (PDT)
Message-ID: <20170330.110856.2114381422765103895.davem@davemloft.net>
References: <06d5884ac36a3ad5f5bceaf0088aede14870088b.1490806853.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934128AbdC3SI6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 14:08:58 -0400
In-Reply-To: <06d5884ac36a3ad5f5bceaf0088aede14870088b.1490806853.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 30 Mar 2017 01:00:53 +0800

> When sending a msg without asoc established, sctp will send INIT packet
> first and then enqueue chunks.
> 
> Before receiving INIT_ACK, stream info is not yet alloced. But enqueuing
> chunks needs to access stream info, like out stream state and out stream
> cnt.
> 
> This patch is to fix it by allocing out stream info when initializing an
> asoc, allocing in stream and re-allocing out stream when processing init.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
