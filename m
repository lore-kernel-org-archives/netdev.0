From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix error return code in
 sctp_send_add_streams()
Date: Wed, 01 Nov 2017 21:26:54 +0900 (KST)
Message-ID: <20171101.212654.2226126937177129059.davem@davemloft.net>
References: <1509456496-93944-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        marcelo.leitner@gmail.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org
To: weiyongjun1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753473AbdKAM1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:27:02 -0400
In-Reply-To: <1509456496-93944-1-git-send-email-weiyongjun1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>
Date: Tue, 31 Oct 2017 13:28:16 +0000

> Fix to returnerror code -ENOMEM from the sctp_make_strreset_addstrm()
> error handling case instead of 0. 'retval' can be overwritten to 0 after
> call sctp_stream_alloc_out().
> 
> Fixes: e090abd0d81c ("sctp: factor out stream->out allocation")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
