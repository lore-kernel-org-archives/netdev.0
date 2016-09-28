From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 08:13:03 -0400 (EDT)
Message-ID: <20160928.081303.661512609700070565.davem@davemloft.net>
References: <cover.1475059350.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcI1MNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:13:11 -0400
In-Reply-To: <cover.1475059350.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 28 Sep 2016 18:46:27 +0800

> This patchset is to improve some codes about prsctp polices, and also
> to fix some issues.
> 
> v1->v2:
>   - wrap the check of chunk->sent_count in a macro:
>     sctp_chunk_retransmitted in patch 2/5.

This series is a mix of bug fixes (patch #1) which should be targetting
'net' and simplifications/cleanups (patch #2-5) which should be targetting
'net-next'.

Please do not mix things up like this, and submit patches targetting
the appropriate tree.
