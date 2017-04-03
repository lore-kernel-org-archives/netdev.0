From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] sctp: add SCTP_PR_STREAM_STATUS sockopt for
 prsctp
Date: Mon, 03 Apr 2017 14:53:01 -0700 (PDT)
Message-ID: <20170403.145301.1291800992412083707.davem@davemloft.net>
References: <0618a2ca7e92ebdfc0953c38da2f727b8b270090.1491037666.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751342AbdDCVxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 17:53:03 -0400
In-Reply-To: <0618a2ca7e92ebdfc0953c38da2f727b8b270090.1491037666.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  1 Apr 2017 17:07:46 +0800

> Before when implementing sctp prsctp, SCTP_PR_STREAM_STATUS wasn't
> added, as it needs to save abandoned_(un)sent for every stream.
> 
> After sctp stream reconf is added in sctp, assoc has structure
> sctp_stream_out to save per stream info.
> 
> This patch is to add SCTP_PR_STREAM_STATUS by putting the prsctp
> per stream statistics into sctp_stream_out.
> 
> v1->v2:
>   fix an indent issue.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
