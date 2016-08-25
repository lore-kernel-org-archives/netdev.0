From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: diag: allow socket bytecode
 filters to match socket marks
Date: Wed, 24 Aug 2016 21:57:36 -0700 (PDT)
Message-ID: <20160824.215736.497441693931042330.davem@davemloft.net>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
        <1472021186-4106-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, ek@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38281 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbcHYE5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 00:57:38 -0400
In-Reply-To: <1472021186-4106-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 24 Aug 2016 15:46:26 +0900

> This allows a privileged process to filter by socket mark when
> dumping sockets via INET_DIAG_BY_FAMILY. This is useful on
> systems that use mark-based routing such as Android.
> 
> The ability to filter socket marks requires CAP_NET_ADMIN, which
> is consistent with other privileged operations allowed by the
> SOCK_DIAG interface such as the ability to destroy sockets and
> the ability to inspect BPF filters attached to packet sockets.
> 
> Tested: https://android-review.googlesource.com/261350
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
