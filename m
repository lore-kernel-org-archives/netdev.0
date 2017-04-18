From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] sctp: add proper process for duplicated
 stream reconf requests
Date: Tue, 18 Apr 2017 13:40:22 -0400 (EDT)
Message-ID: <20170418.134022.1168044044884653759.davem@davemloft.net>
References: <cover.1492264734.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755566AbdDRRka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:40:30 -0400
In-Reply-To: <cover.1492264734.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 15 Apr 2017 22:00:26 +0800

> Now sctp stream reconf will process a request again even if it's seqno
> is less than asoc->strreset_inseq. It may cause a replay attack.
> 
> This patchset is to avoid it by add proper process for all duplicated
> stream reconf requests.

Series applied, thanks.
