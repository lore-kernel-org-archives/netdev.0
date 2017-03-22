From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: declare struct sctp_stream before using it
Date: Wed, 22 Mar 2017 10:58:03 -0700 (PDT)
Message-ID: <20170322.105803.1230372240078516082.davem@davemloft.net>
References: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42348 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934301AbdCVR6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:58:05 -0400
In-Reply-To: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon, 20 Mar 2017 17:46:27 +0800

> sctp_stream_free uses struct sctp_stream as a param, but struct sctp_stream
> is defined after it's declaration.
> 
> This patch is to declare struct sctp_stream before sctp_stream_free.
> 
> Fixes: a83863174a61 ("sctp: prepare asoc stream for stream reconf")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
