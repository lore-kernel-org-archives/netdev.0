From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: handle errors when updating asoc
Date: Tue, 20 Jun 2017 15:33:22 -0400 (EDT)
Message-ID: <20170620.153322.781087834282340962.davem@davemloft.net>
References: <a6aa86ed657155e13c72c246b79cf297159a8765.1497945911.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751842AbdFTTdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:33:24 -0400
In-Reply-To: <a6aa86ed657155e13c72c246b79cf297159a8765.1497945911.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 20 Jun 2017 16:05:11 +0800

> It's a bad thing not to handle errors when updating asoc. The memory
> allocation failure in any of the functions called in sctp_assoc_update()
> would cause sctp to work unexpectedly.
> 
> This patch is to fix it by aborting the asoc and reporting the error when
> any of these functions fails.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Also applied, thank you.
